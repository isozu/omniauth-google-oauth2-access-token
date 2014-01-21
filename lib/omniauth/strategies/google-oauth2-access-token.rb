require 'oauth2'

module OmniAuth
  module Strategies
    class GoogleOauth2AccessToken
      include OmniAuth::Strategy

      BASE_SCOPE_URL = "https://www.googleapis.com/auth/"
      DEFAULT_SCOPE = "userinfo.email,userinfo.profile"

      option :name, 'google_oauth2_access_token'
      option :skip_friends, true
      option :authorize_options, [:access_type, :hd, :login_hint, :prompt, :scope, :state, :redirect_uri]
      option :client_options, {
        :site          => 'https://accounts.google.com',
        :authorize_url => '/o/oauth2/auth',
        :token_url     => '/o/oauth2/token',
        :ssl => { :version => "SSLv3" }
      }

      args [:client_id, :client_secret]
      option :client_id, nil
      option :client_secret, nil

      option :access_token_options, {
        :header_format => 'OAuth %s',
        :param_name => 'access_token'
      }

      attr_accessor :access_token

      def authorize_params
        super.tap do |params|
          options[:authorize_options].each do |k|
            params[k] = request.params[k.to_s] unless [nil, ''].include?(request.params[k.to_s])
          end

          raw_scope = params[:scope] || DEFAULT_SCOPE
          scope_list = raw_scope.split(" ").map {|item| item.split(",")}.flatten
          scope_list.map! { |s| s =~ /^https?:\/\// ? s : "#{BASE_SCOPE_URL}#{s}" }
          params[:scope] = scope_list.join(" ")
          params[:access_type] = 'offline' if params[:access_type].nil?

          session['omniauth.state'] = params[:state] if params['state']
        end
      end

      uid { raw_info['id'] }

      info do
        prune!({
          :name       => raw_info['name'],
          :email      => verified_email,
          :first_name => raw_info['given_name'],
          :last_name  => raw_info['family_name'],
          :image      => image_url(options),
          :urls => {
            'Google' => raw_info['link']
          }
        })
      end

      extra do
        hash = {}
        hash['raw_info'] = raw_info unless skip_info?
        prune! hash
      end

      def raw_info
        @raw_info ||= access_token.get('https://www.googleapis.com/oauth2/v1/userinfo').parsed
      end

      def client
        ::OAuth2::Client.new(options.client_id, options.client_secret, deep_symbolize(options.client_options))
      end

      def request_phase
        form = OmniAuth::Form.new(:title => "User Token", :url => callback_path)
        form.text_field "Access Token", "access_token"
        form.button "Sign In"
        form.to_response
      end

      def callback_phase
        if !request.params['access_token'] || request.params['access_token'].to_s.empty?
          raise ArgumentError.new("No access token provided.")
        end

        self.access_token = build_access_token
        self.access_token = self.access_token.refresh! if self.access_token.expired?

        # TODO: Validate the token

        # Preserve compatibility with the google provider in normal case
        hash = auth_hash
        hash[:provider] = "google"
        self.env['omniauth.auth'] = hash
        call_app!

       rescue ::OAuth2::Error => e
         fail!(:invalid_credentials, e)
       rescue ::MultiJson::DecodeError => e
         fail!(:invalid_response, e)
       rescue ::Timeout::Error, ::Errno::ETIMEDOUT => e
         fail!(:timeout, e)
       rescue ::SocketError => e
         fail!(:failed_to_connect, e)
      end

      protected

      def deep_symbolize(hash)
        hash.inject({}) do |h, (k,v)|
          h[k.to_sym] = v.is_a?(Hash) ? deep_symbolize(v) : v
          h
        end
      end

      def build_access_token
        hash = request.params.slice("access_token", "refresh_token", "expires_in", "token_type")
        ::OAuth2::AccessToken.from_hash(
          client, 
          hash.update(options.access_token_options)
        )
      end

      private

      def prune!(hash)
        hash.delete_if do |_, v|
          prune!(v) if v.is_a?(Hash)
          v.nil? || (v.respond_to?(:empty?) && v.empty?)
        end
      end

      def verified_email
        raw_info['verified_email'] ? raw_info['email'] : nil
      end

      def image_url(options)
        original_url = raw_info['picture']
        return original_url if original_url.nil? || (!options[:image_size] && !options[:image_aspect_ratio])

        image_params = []
        if options[:image_size].is_a?(Integer)
          image_params << "s#{options[:image_size]}"
        elsif options[:image_size].is_a?(Hash)
          image_params << "w#{options[:image_size][:width]}" if options[:image_size][:width]
          image_params << "h#{options[:image_size][:height]}" if options[:image_size][:height]
        end
        image_params << 'c' if options[:image_aspect_ratio] == 'square'

        params_index = original_url.index('/photo.jpg')
        original_url.insert(params_index, ('/' + image_params.join('-')))
      end

      def verify_token(id_token, access_token)
        return false unless (id_token && access_token)

        raw_response = client.request(:get, 'https://www.googleapis.com/oauth2/v2/tokeninfo', :params => {
          :id_token => id_token,
          :access_token => access_token
        }).parsed
        raw_response['issued_to'] == options.client_id
      end

    end
  end
end
