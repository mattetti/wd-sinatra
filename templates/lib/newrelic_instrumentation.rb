require 'new_relic/agent/instrumentation/controller_instrumentation'

DependencyDetection.defer do
  depends_on do
    defined?(WeaselDiesel) && defined?(WeaselDiesel::RequestHandler) &&
      WeaselDiesel::RequestHandler.method_defined?(:dispatch)
  end

  executes do
    NewRelic::Agent.logger.debug 'Installing WeaselDiesel instrumentation'
  end

  executes do
    ::WeaselDiesel::RequestHandler.class_eval do
      include NewRelic::Agent::Instrumentation::WeaselDiesel
      include NewRelic::Agent::Instrumentation::ControllerInstrumentation
      alias dispatch_without_newrelic dispatch
      alias dispatch dispatch_with_newrelic

      add_method_tracer :params_preprocessor_hook if self.method_defined?(:params_preprocessor_hook)
      add_method_tracer :params_postprocessor_hook if self.method_defined?(:params_postprocessor_hook)
      add_method_tracer :pre_dispatch_hook if self.method_defined?(:pre_dispatch_hook)
    end
    # Monitor the actual dispatch of each service
    WSList.all.each do |service|
      service.handler.class_eval do
        add_method_tracer :service_dispatch, 'Service/Dispatch'
      end
    end
  end
end


module NewRelic
  module Agent
    module Instrumentation
      module WeaselDiesel
        include ::NewRelic::Agent::Instrumentation::ControllerInstrumentation

        def dispatch_with_newrelic(app)
          perform_action_with_newrelic_trace(:category => :controller,
                                             :class_name => service.class.name,
                                             :controller => service.class.name,
                                             :path => "#{service.verb.upcase} #{service.url}",
                                             :name => "#{service.verb.upcase} #{service.url}",
                                             :params => filter_newrelic_params(app.params),
                                             :request => app.request) do
            dispatch_without_newrelic(app)
          end
        end

        # filter params based the newrelic.yml entry if it exists.
        def filter_newrelic_params(params)
          @filters ||= NewRelic::Control.instance['filter_parameters']
          return params if @filters.nil? || @filters.empty?
          duped_params = params.dup
          duped_params.each{|k,v| duped_params[k] = 'FILTERED' if @filters.include?(k) }
          duped_params
        end

      end
    end
  end
end

DependencyDetection.detect!
