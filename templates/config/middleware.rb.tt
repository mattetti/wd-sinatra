if defined?(NewRelic)
  #if RACK_ENV == 'development'
    #require 'new_relic/rack/developer_mode'
    #use NewRelic::Rack::DeveloperMode
  #end
  if NewRelic::Agent.config[:agent_enabled]
    LOGGER.info "New Relic monitoring enabled App name: '#{NewRelic::Control.instance['app_name']}', Mode: '#{NewRelic::Control.instance.app}'"
  end
end

class <%= name_const %> < Sinatra::Base
  # Use this middleware with AR to avoid threading issues.
  # require 'active_record'
  # use ActiveRecord::ConnectionAdapters::ConnectionManagement

  use Airbrake::Rack if defined?(Airbrake)

  use Rack::ContentLength

  require "rack/parser"
  use Rack::Parser
end
