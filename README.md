# OmniAuth Google OAuth2 Access Token Strategy

Google OAuth2 Access Token Strategy in OmniAuth 1.0.

This strategy is fully inspired by [omniauth-facebook-access-token](https://github.com/SoapSeller/omniauth-facebook-access-token).

Find your API key at: https://code.google.com/apis/console/

Read the Google docs for more details: https://developers.google.com/accounts/docs/OAuth2

## Installation

Add to your `Gemfile`:

```ruby
gem 'omniauth-google-oauth2-access-token'
```

Then `bundle install`.

## Usage

### Server-Side

`OmniAuth::Strategies::GoogleOauth2AccessToken` is simply a Rack middleware.
Find the detailed instructions in OmniAuth 1.0 docs: https://github.com/intridea/omniauth.
A brief example, using the middleware in a Rails application at `config/initializers/omniauth.rb`:

```ruby
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2_access_token, ENV['GOOGLE_CLIENT_KEY'], ENV['GOOGLE_CLIENT_SECRET']
end
```

### Client-Side

Request the `access_token` to the provider, then login via ajax GET/POST call to `/auth/google_oauth2_access_token/callback` while providing `access_token` parameter.

## License

Copyright (c) 2013 by Masaaki Isozu

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
