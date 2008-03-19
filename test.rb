require 'rubygems'
require 'rack'
require 'rack/lobster'

application = Rack::Lobster.new

server = "mongrel"

case server
when "mongrel"
  server = Rack::Handler::Mongrel
when "webrick"
  server = Rack::Handler::WEBrick
when "cgi"
  server = Rack::Handler::CGI
when "fastcgi"
  server = Rack::Handler::FastCGI
else
  server = Rack::Handler.const_get(server.capitalize)
end

server.run application, {:Port => 9292, :Host => "0.0.0.0", :AccessLog => []}
