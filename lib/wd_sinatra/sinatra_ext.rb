require 'forwardable'
require 'params_verification'
require 'json'

class WeaselDiesel

  # @return [RequestHandler] The reference handler that gets cloned for each request.
  #  Every time you call `service.handler`, you get a clone of the alpha_handler. This getter
  #  is here in case you need to change something to the reference handler.
  attr_reader :alpha_handler

  class RequestHandler
    extend Forwardable

    # @return [WeaselDiesel] The service served by this controller
    # @api public
    attr_reader :service

    # @return [Sinatra::Application]
    # @api public
    attr_reader :app

    # @return [Hash]
    # @api public
    attr_reader :env

    # @return [Sinatra::Request]
    # @see http://rubydoc.info/github/sinatra/sinatra/Sinatra/Request
    # @api public
    attr_reader :request

    # @return [Sinatra::Response]
    # @see http://rubydoc.info/github/sinatra/sinatra/Sinatra/Response
    # @api public
    attr_reader :response

    # @return [Hash]
    # @api public
    attr_accessor :params

    attr_accessor :current_user

    # The service controller might be loaded outside of a Sinatra App
    # in this case, we don't need to load the helpers
    if Object.const_defined?(:Sinatra)
      include Sinatra::Helpers
    end

    def initialize(service, &block)
      @service = service
      @implementation = block
    end

    def dispatch(app)
      @app      = app
      @env      = app.env
      @request  = app.request
      @response = app.response
      @service  = service

      begin
        # raises an exception if the params are not valid
        # otherwise update the app params with potentially new params (using default values)
        # note that if a type is mentioned for a params, the object will be cast to this object type
        #
        # removing the fake sinatra params since v1.3 added this. (should be eventually removed)
        if app.params['splat']
          processed_params = app.params.dup
          processed_params.delete('splat')
          processed_params.delete('captures')
        end
        @params = (processed_params || app.params)
        @params = params_preprocessor_hook(@params) if self.respond_to?(:params_preprocessor_hook)
        @params = ParamsVerification.validate!(@params, service.defined_params)
        @params = params_postprocessor_hook(@params) if self.respond_to?(:params_postprocessor_hook)
      rescue Exception => e
        LOGGER.error e.message
        LOGGER.error "passed params: #{app.params.inspect}"
        if self.respond_to?(:params_exception_handler)
          params_exception_handler(e)
        else
          halt 400, {'Content-Type' => 'application/json'}, {:error => e.message}.to_json
        end
      end

      pre_dispatch_hook if self.respond_to?(:pre_dispatch_hook)
      service_dispatch
    end

    # Forwarding some methods to the underlying app object
    def_delegators :app, :settings, :halt, :compile_template, :session

    private ##################################################

  end # of RequestHandler


  # Creates a new handler per request to dispatch
  # by cloning the alpha handler
  def handler
    @alpha_handler.clone
  end

  def implementation(&block)
    if block_given?
      @alpha_handler = RequestHandler.new(self, &block)
      @alpha_handler.define_singleton_method(:service_dispatch, block)
    end
    @alpha_handler
  end

  def load_sinatra_route(sinatra_app=nil)
    sinatra_app ||= Sinatra::Base
    service     = self
    upcase_verb = service.verb.to_s.upcase
    unless ENV['DONT_PRINT_ROUTES']
      LOGGER.info "Available endpoint: #{self.http_verb.upcase} #{self.url}"
    end
    raise "DSL is missing the implementation block" unless ['SKIP_SERVICE_CHECK'] || self.handler

    # Define the route directly to save some object allocations on the critical path
    # Note that we are using a private API to define the route and that unlike sinatra usual DSL
    # we do NOT define a HEAD route for every GET route.
    sinatra_app.send(:route, upcase_verb, self.url) do
      env['wd.service'] = service
      service.handler.dispatch(self)
    end

  end

end
