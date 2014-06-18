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

    def config endpoint
      config_hash[endpoint.to_s]
    end

    def config_hash
      @_config_hash ||= YAML.load_file(@config_file)[Rails.env] if File.exists?(@config_file)
    end

    def endpoints
      config_hash.inject([]){|res, (k,v)| res << k; res}
    end

    def endpoint_active? endpoint
      endpoints.include?(endpoint.to_s)
    end
  end

end
