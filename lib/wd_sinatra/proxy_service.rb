# Offers a simple way to delegate/proxy a new endpoint to an existing
# one. Very practical to deprecate old urls but to still have them
# working:
#
#   describe_service "api/foo/v1/:id" do |service|
#      service.http_verb :put
#
#      # load the dependent service before but avoid loading it twice.
#      service.load_dependency_service "legacy/foo_update_service"
#      service.proxy = WSList.find(:put, "/api/v1/:id")
#
#      service.documentation do |doc|
#        doc.overall "Deprecated, use PUT '/api/v1/:id' to update a foo."
#      end
#
#    end
#
class WeaselDiesel

  attr_reader :proxy

  # Sets a proxy service which will handle the requests coming to the defined service.
  #
  def proxy=(opts)
    @proxy = ProxyService.new(opts)
    @alpha_handler = @proxy.proxied_handler
  end

  # Loads an API file from the api folder but it uses the same path
  # defined when loading all services so the service isn't loaded twice and raising an exception
  # when WD detects a duplicated service.
  #
  # @param [String] service_path The filename/path of the service to load relative to the API folder.
  def load_dependency_service(service_path)
    require File.join(WDSinatra::AppLoader.root_path, "api", service_path )
  end

  class ProxyService

    attr_accessor :to, :proxied_handler

    def initialize(opts)
      if opts.is_a?(Hash)
        proxy_implementation_to opts.delete(:implementation)
      elsif opts.is_a?(WeaselDiesel)
        proxy_implementation_to opts
      else
        raise ArgumentError
      end
    end

    private

    def proxy_implementation_to(obj)
      return unless obj
      if obj.is_a?(WeaselDiesel)
        self.to = obj
        self.proxied_handler = self.to.handler
      end
    end
  end

end
