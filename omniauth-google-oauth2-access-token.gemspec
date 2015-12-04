# -*- encoding: utf-8 -*-
require File.expand_path('../lib/omniauth-google-oauth2-access-token/version', __FILE__)

Gem::Specification.new do |gem|
  gem.add_dependency 'omniauth', '>= 1.0'
  gem.add_dependency 'oauth2', '>= 0.8.0'

  gem.authors       = ["Masaaki Isozu"]
  gem.email         = ["m.isozu@gmail.com"]
  gem.license       = 'MIT'
  gem.description   = %q{A Google OAuth2 using access-token strategy for OmniAuth. Can be used for client side Google login. }
  gem.summary       = %q{A Google OAuth2 using access-token strategy for OmniAuth.}
  gem.homepage      = "https://github.com/isozu/omniauth-google-oauth2-access-token"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.name          = "omniauth-google-oauth2-access-token"
  gem.require_paths = ["lib"]
  gem.version       = OmniAuth::GoogleOAuth2AccessToken::VERSION
end
