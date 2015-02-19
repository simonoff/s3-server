# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Rails.application

require 'rack/cors'
use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: [:get, :post, :put, :patch, :delete, :options]
  end
end

# Work-around for https://github.com/rack/rack/issues/318
# A higher exposure to POST parsing DOS attacks. But it's dummy s3 server.
Rack::Utils.key_space_limit = 262_144
