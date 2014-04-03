require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/core_ext/string/inflections'

module ApiNotify

  class << self
    attr_accessor :configuration

    # Start a ApiNotify configuration block in an initializer.
    #
    # example: Provide a default currency for the application
    #   ApiNotify.configure do |config|
    #     config.active = true
    #   end
    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end
  end

  # ApiNotify configuration module.
  # This is extended by ApiNotify to provide configuration settings.
  class Configuration

    attr_accessor :active, :config_file

    # Configuration parameters
    def initialize
      @active = true
      @config_file = "#{Rails.root.to_s}/config/api_notify.yml"
    end

  end

end
