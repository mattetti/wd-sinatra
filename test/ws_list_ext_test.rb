require 'uri'
require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class WsListExtTest < MiniTest::Unit::TestCase

  def char_encoded(char)
    enc = URI.escape(char)
    enc = "(?:#{escaped(char, enc).join('|')})" if enc == char
    enc = "(?:#{enc}|#{encoded('+')})" if char == " "
    enc
  end

  def clear_ws_list
    WSList.all.clear
    assert WSList.all.length == 0
  end

  def add_test_services
    WSList.add WeaselDiesel.new("/foo")
    WSList.add WeaselDiesel.new("/foo/:bar")
    WSList.add WeaselDiesel.new("/foo/bar/")
    WSList.add WeaselDiesel.new("/foo/bart")
    WSList.add WeaselDiesel.new("/foo/bar/:baz")
    WSList.add WeaselDiesel.new("/foo/bar/bazz")
    WSList.add WeaselDiesel.new("/foo/:id/bazz")
  end

  # A snapshot of a working sorting of url array
  # The sorting doesn't have to actually be similar to that
  # but this allows us to have a baseline to measure against in case 
  # of tests.
  def expected_sorted_urls
    [
      "/foo/bar/bazz", 
      "/foo/bart",
      "/foo/bar/",
      "/foo/bar/:baz",
      "/foo/:id/bazz",
      "/foo/:bar",
      "/foo"
    ]
  end

  def matched_route(url, reference_urls)
    sorted_regexps = reference_urls.map do |url|
      ignore = ""
      pattern = url.gsub(/[^\?\%\\\/\:\*\w]/){ |c| 
        ignore << escaped(c).join if c.match(/[\.@]/)
        char_encoded(c) 
      }
      pattern.gsub!(/((:\w+)|\*)/) do |match|
        if match == "*"
          "(.*?)"
        else
          "([^#{ignore}/?#]+)"
        end
      end
      /\A#{pattern}\z/
    end

    regexp_match = sorted_regexps.detect{|r| r.match(url) }
    if regexp_match
      regexp_match.source[/\\A(.*?)\\z/, 1]
    else
      nil
    end

  end

  def assert_route_matching(base_urls)
    assert_equal "/foo", matched_route("/foo", base_urls), "Matching /foo to /foo, #{base_urls}"
    assert_equal "/foo/bar/bazz", matched_route("/foo/bar/bazz", base_urls)
    assert_equal "/foo/bart", matched_route("/foo/bart", base_urls)
    assert_equal "/foo/bar/", matched_route("/foo/bar/", base_urls)
    assert_equal "/foo/bar/([^/?#]+)", matched_route("/foo/bar/foo", base_urls)
    assert_equal "/foo/([^/?#]+)", matched_route("/foo/baz", base_urls)
    assert_equal nil, matched_route("/fooz", base_urls), "shouldn't match /fooz"
    assert_equal nil, matched_route("/foo/bar/baz/baz", base_urls), "shouldn't match /foo/bar/baz/baz"
    assert_equal nil, matched_route("/foo/", base_urls), "shouldn't match /foo/"
    assert_equal "/foo/([^/?#]+)/bazz", matched_route("/foo/123/bazz", base_urls), "Should match /foo/123/bazz" 
  end

  def test_route_matching_expectations
    clear_ws_list
    add_test_services
    assert_route_matching(expected_sorted_urls)
  end

  def test_route_loading_and_matching
    clear_ws_list
    add_test_services
    assert_route_matching(WSList.sorted_for_sinatra_load.map{|ws| ws.url})
  end

end
