ENV['RACK_ENV'] ||= 'test'
require 'test/unit'
require 'rack'
require 'rack/test'
require 'json'
require 'weasel_diesel'
require 'wd_sinatra/app_loader'
require 'json_response_verification'

WeaselDiesel.send(:include, JSONResponseVerification)
ENV['DONT_PRINT_ROUTES'] = 'true'

class Requester
  include ::Rack::Test::Methods

  def app
    Sinatra::Application
  end
end

module TestApi
  module_function

  URL_PLACEHOLDER = /\/*(:[a-z A-Z _]+)\/*/

  # Sets the X header name to make auth'd requests.
  def auth_request_x_header=(val)
    @auth_request_x_header = val
  end

  # getter for the auth X header
  def auth_request_x_header
    @auth_request_x_header
  end

  # Sets the X header name for mobile auth'd requests
  def mobile_request_x_header=(val)
    @mobile_request_x_header = val
  end

  # getter for the mobile X header
  def mobile_request_x_header
    @mobile_request_x_header
  end

  def request(verb, uri, params={}, headers=nil)
    params ||= {}
    service_uri = uri.dup
    matching = uri.scan URL_PLACEHOLDER
    unless matching.empty?
      # replace the placeholder by real value
      matching.flatten.each_with_index do |str, idx|
        key = str.delete(":").to_sym
        value = params[key].to_s
        # delete the value from the params
        params.delete(key)
        uri = uri.gsub(str, value)
        end
    end
    
    @request = Requester.new
    yield @request if block_given?
    headers.each {|name, value| @request.header(name, value) } if headers
    response = @request.send(verb, uri, params)
    @json_response = JsonWrapperResponse.new(response, :verb => verb, :uri => service_uri)
  end

  def mobile_account=(account)
    @account = account
  end

  def get(uri, params=nil, headers=nil)
    request(:get, uri, params, headers)
  end

  def internal_get(uri, params=nil, headers=nil)
    get(uri, params, valid_internal_api_headers(headers))
  end

  def mobile_get(uri, params=nil, headers=nil)
    request(:get, uri, params, mobile_headers(headers))
  end

  def post(uri, params=nil, headers=nil)
    request(:post, uri, params, headers)
  end

  def internal_post(uri, params=nil, headers=nil)
    post(uri, params, valid_internal_api_headers(headers))
  end

  def mobile_post(uri, params=nil, headers=nil)
    request(:post, uri, params, mobile_headers(headers))
  end

  def put(uri, params=nil, headers=nil)
    request(:put, uri, params, headers)
  end

  def internal_put(uri, params=nil, headers=nil)
    put(uri, params, valid_internal_api_headers(headers))
  end

  def mobile_put(uri, params=nil, headers=nil)
    request(:put, uri, params, mobile_headers(headers))
  end

  def delete(uri, params=nil, headers=nil)
    request(:delete, uri, params, headers)
  end

  def internal_delete(uri, params=nil, headers=nil)
    delete(uri, params, valid_internal_api_headers(headers))
  end

  def mobile_delete(uri, params=nil, headers=nil)
    request(:delete, uri, params, mobile_headers(headers))
  end

  def head(uri, params=nil, headers=nil)
    request(:head, uri, params, headers)
  end

  def internal_head(uri, params=nil, headers=nil)
    head(uri, params, valid_internal_api_headers(headers))
  end

  def mobile_head(uri, params=nil, headers=nil)
    request(:head, uri, params, mobile_headers(headers))
  end

  def json_response
    @json_response
  end

  def last_request
    @request
  end

  def last_response
    @json_response.rest_response if @json_response
  end

  # Define this method in your test helpers
  def valid_internal_api_headers(headers)
    raise 'NotImplemented, You need to implement this method yourself'
  end

  # Define this method in your test helpers

  def mobile_headers(headers)
    raise 'NotImplemented, You need to implement this method yourself'
  end

end


# Wrapper around a rest response
class JsonWrapperResponse
  extend Forwardable

  attr_reader :rest_response
  attr_reader :verb
  attr_reader :uri

  def initialize(response, opts={})
    @rest_response = response
    @verb = opts[:verb]
    @uri = opts[:uri]
  end

  def body
    @body ||= JSON.load(rest_response.body) rescue rest_response.body
  end

  def success?
    @rest_response.status == 200
  end
  
  def redirected?
    @rest_response.status.to_s =~ /30\d/
  end

  def [](val)
    if body
      body[val.to_s]
    else
      nil
    end
  end

  def method_missing(meth, *args)
    body.send(meth, args)
  end

  def_delegators :rest_response, :code, :headers, :raw_headers, :cookies, :status, :errors
end
