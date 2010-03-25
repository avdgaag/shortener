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
    assert_match /URL Shortener/, last_response.body
  end

  def test_shorten_redirects_to_info
    post '/shorten', :url => 'http://example.com'
    assert last_response.redirect?
    assert_match %r{/info/.*}, last_response.location
  end

  def test_shows_new_and_old_urls
    post '/shorten', :url => 'http://example.com'
    follow_redirect!
    assert last_response.ok?
    assert_match /example.com/, last_response.body
    assert_match /shortener.arjanvandergaag.nl\/.+/, last_response.body
  end

  def test_should_not_shrink_non_urls
    post '/shorten', :url => 'foo'
    assert last_response.server_error?
  end
end