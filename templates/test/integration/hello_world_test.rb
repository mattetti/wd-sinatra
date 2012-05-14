require 'test_helpers'

class HelloWorldIntegrationTest < MiniTest::Unit::TestCase

  def test_default_response
    TestApi.get "/hello_world"
    assert_api_response
    assert_equal "Hello World", TestApi.json_response['message']
    assert Time.parse(TestApi.json_response['at']) < Time.now
  end

  def test_customized_response
    TestApi.get "/hello_world", :name => "Matt"
    assert_api_response
    assert_equal "Hello Matt", TestApi.json_response['message']
    assert Time.parse(TestApi.json_response['at']) < Time.now
  end

end
