require 'rubygems'

require 'erubis'

require 'fleet/version'
require 'fleet/log'
require 'fleet/helpers'

begin
  require 'swiftcore/evented_mongrel'
rescue
  # Don't have it?  No problem!
end

require 'rack'
require 'rack/file'

begin
  Dir.entries("plugins/").select{|entry| entry =~ /(.*).rb$/}.each do |helper_file|
    Fleet::Helpers.module_eval(File.open(helper_file).read)
  end
rescue
  # No helpers
end

module Fleet
  # Launches the Mongrel handler.
  class Server
    def self.run(options)
      Log.enter "- fleet version #{VERSION::STRING}"
      Log.enter "\t starting server on port #{options[:port]}"
      Log.enter

      application = Handler.new(options)

      server = Rack::Handler::Mongrel
            
      case options[:server]
      when "mongrel"
        server = Rack::Handler::Mongrel
      when "thin"
        begin
          require 'thin'
          server = Rack::Handler::Thin
        rescue LoadError
          puts "You don't have Thin installed!"
          exit
        end
      when "webrick"
        server = Rack::Handler::WEBrick
      when "cgi"
        server = Rack::Handler::CGI
      when "fastcgi"
        server = Rack::Handler::FastCGI
      end

      server.run application, {:Port => options[:port], :Host => "0.0.0.0", :AccessLog => []}
    rescue Interrupt, Mongrel::StopServer
      Log.enter
      Log.enter "- interrupt signal caught"
      Log.enter "\tshutting server down"
      Log.enter
      exit 0
    end
  end
end