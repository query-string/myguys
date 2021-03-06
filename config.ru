#### rails-rumble redirect
require 'rack-rewrite'
DOMAIN = ENV['DOMAIN']
use Rack::Rewrite do
  r301 %r{.*}, "https://#{DOMAIN}$&", if: Proc.new {|rack_env|
    rack_env['SERVER_NAME'] != DOMAIN && ENV['RACK_ENV'] == "production"
  }
end
####

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application
