require 'body_parser' # from the lib folder
# Change the JSON parser if you want to use Yajl for instance.
require 'json'
BodyParser.json_parser = JSON

module WDSinatraHooks

  MOBILE_X_HEADER   = 'HTTP_X_MOBILE_TOKEN'
  INTERNAL_X_HEADER = 'HTTP_X_INTERNAL_API_KEY'
  JSON_BODY_VERBS   =  %w(POST PUT DELETE)

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
  def params_preprocessor_hook(params)
    if JSON_BODY_VERBS.include?(request.request_method)
      BodyParser.parse(params, request.body, request.content_type)
    else
      params
    end
  end


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
  #
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
