require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'carrierwave'
require 'carrierwave/orm/activerecord'
require_relative '../lib/chunked_transfer_decoder'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module S3Server
  class Application < Rails::Application
    config.middleware.insert_before 'Rack::Runtime', "ChunkedTransferDecoder", decoded_upstream: false
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    config.autoload_paths += %W(#{config.root}/lib/)
    config.autoload_paths += %W(#{config.root}/lib/modules/)
    config.autoload_paths += %W(#{config.root}/lib/tasks/)

    # Remove warnings raised by CarrierWave with Rails 4.2
    config.active_record.raise_in_transactional_callbacks = true
  end
end
