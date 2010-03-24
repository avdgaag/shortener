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
<!DOCTYPE html>
<html>
    <head>
        <meta name="charset" content="UTF-8">
        <title>Shrink URLs</title>
        <style type="text/css" media="screen">
            body {
                margin: 60px 0;
                text-align: center;
                font: 14px/20px Helvetica, Arial, sans-serif;
                color: #333;
                background: #f3f3f3;
            }
            article {
                display: block;
                margin: 0 auto;
                text-align: left;
                width: 400px;
                padding: 0 20px;
                background: #fff;
                border: 1px solid #eee;
                border-bottom-color: #ddd;
                border-right-color: #ddd;
                -webkit-border-radius: 10px;
                -moz-border-radius: 10px;
                border-radius: 10px;
                -webkit-box-shadow: 5px 5px 2px #eee;
            }
            footer {
                text-align: center;
                color: #999;
                font-size: 11px;
            }
            h1 {
                font-size: 20px;
                text-shadow: 1px 1px 1px #ddd;
            }
            h1, p, form, header, footer {
                display: block;
                margin: 20px 0;
            }
            input {
                font: 18px/20px Helvetica, Arial, sans-serif;
                padding: 5px;
                width: 280px;
            }
            button {
                font: 18px/20px Helvetica, Arial, sans-serif;
                padding: 5px;
            }
        </style>
    </head>
    <body>
        <article>
            <%= yield %>
            <footer>
                &copy; copyright 2010 Arjan van der Gaag.
            </footer>
        </article>
    </body>
</html>
@@ home
<header>
    <h1>URL Shortener</h1>
    <p>Paste a URL into the form below and have it shortened for your sharing pleasures:</p>
</header>
<form action="/shorten" method="post" accept-charset="utf-8">
    <div>
        <input type="text" name="url" size="30" maxsize="60" placeholder="http://your-url.com">
        <button type="submit" name="submit" value="submit">Shrink it!</button>
    </div>
</form>
@@ shortened
<header>
  <h1>Your URL has been enshrunked!</h1>
</header>
<p><a href="http://shortener.arjanvandergaag.nl/<%= u[0] %>">http://shortener.arjanvandergaag.nl/<%= u[0] %></a> now points to <a href="<%= u[1] %>"><%= u[1] %></a>.</p>