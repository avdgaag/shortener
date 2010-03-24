require 'rubygems'
require 'test/unit'
require 'rack/test'
require 'shortener'

class TestShortener < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_home_renders_content
    get '/'
    assert last_response.ok?
    assert_match /Shortener/, last_response.body
  end

  def test_shorten_redirects_to_info
    post '/shorten', :url => 'http://example.com'
    assert_equal 302, last_response.status
    assert_match %r{/info/.*}, last_response['Location']
  end
end