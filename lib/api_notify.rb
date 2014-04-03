require "api_notify/version"
require "api_notify/hooks"
require "api_notify/configuration"

module ApiNotify

end

if defined? Rails
  require "api_notify/railtie"
  require "api_notify/engine"
end
