require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module Kinetic
  class Application < Rails::Application
    config.autoload_paths += %W{
      #{config.root}/app/builders
      #{config.root}/app/services
      #{config.root}/app/inputs
      #{config.root}/app/models/engine
    }
    config.assets.initialize_on_precompile = false
    config.encoding = "utf-8"
    config.filter_parameters += [:password]
    config.active_support.escape_html_entities_in_json = true
    config.active_record.whitelist_attributes = false
    config.assets.enabled = true
    config.assets.version = '1.0'
  end
end
