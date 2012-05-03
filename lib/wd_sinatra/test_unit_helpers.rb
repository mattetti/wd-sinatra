require 'wd_sinatra/test_helpers'

module TestUnitHelpers
  # Custom assertions
  def assert_api_response(response=nil, message=nil)
    response ||= TestApi.json_response
    print response.rest_response.errors if response.status === 500
    assert response.success?, message || ["Body: #{response.rest_response.body}", "Errors: #{response.errors}", "Status code: #{response.status}"].join("\n")
    service = WSList.all.find{|s| s.verb == response.verb && s.url == response.uri[1..-1]}
    raise "Service for (#{response.verb.upcase} #{response.uri[1..-1]}) not found" unless service
    unless service.response.nodes.empty?
      assert response.body.is_a?(Hash), "Invalid JSON response:\n#{response.body}"
      valid, errors = service.validate_hash_response(response.body)
      assert valid, errors.join(" & ") || message
    end
  end

  def assert_api_response_with_redirection(redirection_url=nil)
    response = TestApi.json_response
    print response.rest_response.errors if response.status === 500
    assert response.status == 302, "Redirection expect, but got #{response.status}"
    if redirection_url
      assert response.headers["location"], redirection_url
    end
  end
end
