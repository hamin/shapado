require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'active_resource/railtie'
require 'rails/test_unit/railtie'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module Shapado
  class Application < Rails::Application
    require File.expand_path('../load_config', __FILE__)
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  
    # Add additional load paths for your own custom dirs
    config.autoload_paths += %W( #{Rails.root}/app/middlewares #{Rails.root}/app/models/widgets )
  
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
  
    config.action_mailer.delivery_method = :sendmail
    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  
    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names.
    config.time_zone = 'UTC'
  
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    config.i18n.load_path += Dir[File.join(Rails.root, 'config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :en
    config.action_controller.use_accept_header = false
    # middlewares
    config.middleware.use "MongoMapperMiddleware"
    config.middleware.use "DynamicDomain"
    config.middleware.use "MongoMapperExt::FileServer"
    if AppConfig.recaptcha["activate"]
      config.middleware.use "Rack::Recaptcha", :public_key => AppConfig.recaptcha["public_key"],
                                               :private_key => AppConfig.recaptcha["private_key"],
                                               :paths => nil
    end
  end
end
