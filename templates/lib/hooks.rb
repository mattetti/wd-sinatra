module WDSinatraHooks

  MOBILE_X_HEADER   = 'HTTP_X_MOBILE_TOKEN'
  INTERNAL_X_HEADER = 'HTTP_X_INTERNAL_API_KEY'
  SUPPORTED_MEDIA_TYPES = {
    "application/json" => :json,
    "application/xml" => :xml,
    # add custom media types here, for example:
    # "application/vnd.example+json" => :json,
  }

  ####### HOOKS #############################
  #
  # This hook gets called before the params
  # are being verified. It's a good place to add a content type
  # handler for instance like shown below.
  # If you don't need this hook, just delete it.
  # Note that you have access to the request context, see sinatra_ext.rb
  # in the wd_sinatra repository to see how this is implemented.
  #
  # @param [Hash] params the incoming params.
  # processed.
  # @returns [Hash] the pre processed params.
  # def params_preprocessor_hook(params)
  # end


  # This hooks gets called when an exception is raised while preprocessing the params,
  # verifying them or post processing them.
  # If this method isn't defined, the default handler is used (a 400 error is returned with the
  # exception message sent back as a json.
  #
  # @param [Exception] exception The exception that was rescued.
  # def params_exception_handler(exception)
  #   # example implementation:
  #   # halt 400, {'Content-Type' => 'application/json'}, {:error => exception.message}.to_json
  # end

  # This hook gets called after the params are being verified.
  # You can use this hook to modify the params before sending them to
  # your service.
  #
  # @param [Hash] params the incoming params.
  # processed.
  # @returns [Hash] the post processed params.
  # def params_postprocessor_hook(params)
  # end

  # This hook gets called before dispatching any
  # requests.
  #
  # Implementation example
  def pre_dispatch_hook
    # content negotiation
    require "rack/accept"
    accept = env["rack-accept.request"]
    service_media_types = SUPPORTED_MEDIA_TYPES.select {|k,v| service.formats.include?(v)}
    env["wd.media_type"] = accept.media_type.best_of(service_media_types.keys)
    halt 406 unless env["wd.media_type"]
    env["wd.format"] =  SUPPORTED_MEDIA_TYPES[env["wd.media_type"]]
    content_type env["wd.format"], charset: "utf-8"

    if service.extra[:mobile]
      mobile_auth_check
    elsif service.extra[:internal]
      internal_api_key_check
    elsif !service.auth_required
      return
    else
      halt 403 # protect by default
    end
  end

  #########################################

  # AUTHENTICATION

  # Implementation example
  def mobile_auth_check
    true
  end

  # Implementation example
  def internal_api_key_check
    true
  end

end

Sinatra::Helpers.send(:include, WDSinatraHooks)
WeaselDiesel::RequestHandler.send(:include, WDSinatraHooks)

# NEW RELIC HOOKS
# uncomment if you want to use newrelic (you also need the wd_newrelic_rpm gem)
# require 'newrelic_instrumentation'
