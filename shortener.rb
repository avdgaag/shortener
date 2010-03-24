require 'rubygems'
require 'sinatra'
require 'json'

set :show_exceptions, false
enable :inline_templates

class Shortener
  attr_reader :store, :urls

  def initialize(store)
    @store = store
    @urls = JSON.load((File.read(store) rescue '{}'))
  end

  def save
    File.open(store, 'w') { |f| f.write(@urls.to_json) }
  end

  def generate_token
    token = rand(36**6).to_s(36)
    token = generate_token if @urls.has_key?(token)
    token
  end

  def shorten(url)
    return @urls.invert[url] if @urls.has_value?(url)
    hash = generate_token
    @urls[hash] = url
    save
    hash
  end

  def lookup(hash)
    return hash, @urls[hash]
  end
end

before do
  @shorten = Shortener.new('shorten.js')
  content_type 'text/html', :charset => 'utf-8'
end

error do
  "An error occured: " + env['sinatra.error']
end

get '/' do
  erb :home
end

post '/shorten' do
  begin
    uri = URI.parse(params['url'])
    raise URI::InvalidURIError unless uri.class == URI::HTTP
  end
  redirect '/info/' + @shorten.shorten(params['url'])
end

get '/info/:hash' do |h|
  erb :shortened, :locals => { :u => @shorten.lookup(h) }
end

get '/h/:hash' do |h|
  redirect @shorten.lookup(h)
end
__END__
@@ layout
<!doctype html>
<html>
  <head>
    <meta charset="utf-8">
    <title>Shortener</title>
  </head>
  <body>
    <h1>URL Shortener</h1>
    <%= yield %>
    <p>by Arjan van der Gaag</p>
  </body>
</html>
@@ home
<form action="/shorten" method="post" accept-charset="utf-8">
  <input type="text" name="url" placeholder="Paste a URL...">
  <input type="submit" value="Shorten now &rarr;">
</form>
@@ shortened
<p>The short URL <a href="http://shortener.arjanvandergaag.nl/<%= u[0] %>">http://shortener.arjanvandergaag.nl/<%= u[0] %></a> now points to <a href="<%= u[1] %>"><%= u[1] %></a>.</p>