require 'rubygems'
require 'mongrel'
require 'erubis'
require 'erb'

require 'mime/types'
require 'yaml'

require 'fleet/renderer'
require 'fleet/base_controller'
require 'fleet/router'
require 'fleet/errors'

# We'll be ORM agnostic soon...
require 'active_record'

module Fleet
  # The Mongrel HTTP Handler.  Handles all operations with requests.
  class Handler   
    def initialize(options)
      # Make our configuration options avialable to the handler
      @options = options
      
      # Setup a DirHandler for sending static files securely
      @static_handler = Rack::File.new("static/")
      
      # Setup the router
      Log.enter "- Setting up routes"
      @router = Router.new
      @router.instance_eval(File.open("config/routes.rb").read)
      
      # Setup database connection
      Log.enter "- Setting up database connection"
      database_config = YAML::load_file('config/database.yml')

      ActiveRecord::Base.establish_connection(
        database_config["development"]
      )
      
      # Grab the controller classes
      # TODO: Pull into method so we can allow reloading
      Log.enter "- Loading controllers"
      Dir.entries("app/controllers").select{|entry| entry =~ /(.*).rb$/}.each do |controller_file|
        ApplicationSpace.module_eval(File.open("app/controllers/#{controller_file}").read)
      end
      
      # Grab the model classes
      Log.enter "- Loading models"
      Dir.entries("app/models").select{|entry| entry =~ /(.*).rb$/}.each do |model_file|
        ApplicationSpace.module_eval(File.open("app/models/#{model_file}").read)
      end
      
      # Inject our helpers in the BaseController class to make them
      # available on each request.
      include_helpers
    end
  
    # Main request handler for Mongrel.
    def call(env)
      # Setup up the request's context (response and request information)
      request = Rack::Request.new(env)

      # Setup our request's path
      @request_path = request.path_info
    
      # Initialize the buffered log entry
      log_entry = ""
      log_entry << "*** request for [#{request.url}] from [#{env['REMOTE_ADDR']}]\n"

      # If it's a root request, we want to render the template we configured
      @request_path = @options[:root] if @request_path == '/'
      
      # Is it a static file?
      if (@request_path =~ /\.(.*)$/)
        puts "static#{@request_path}"
        if File.exist?("static#{@request_path}")
          # Yes?  Let our static handler take it away!
          log_entry << "    response: [200]\n"
          log_entry << "    rendering [#{@request_path}]\n"
        
          @static_handler.call(env)
        else
          # Page not found
          # Log the 404
          log_entry << "    response: [404]\n"
          log_entry << "    rendering 'page not found'\n"

          # Send back the default or a custom template
          content = @options[:errors] && @options[:errors][:not_found] ? Renderer.send(@options[:templates].to_sym, File.open("#{@options[:path]}#{@options[:errors][:not_found]}.#{@options[:templates]}", "r").read, context) : ErrorReporter.not_found(@request_path, request.params['REMOTE_ADDR'], @params)
          [200, {'Content-Type' => 'text/html'}, content]
        end
      else
        # No!  Render a template...
        route = @router.recognize(@request_path)
        
        controller = "Fleet::ApplicationSpace::#{route[:controller].camelize}".constantize.new(request, route[:action])
        content = controller.send(route[:action].to_sym)
                
        # Set the content type if we're responding with a render
        controller.response.headers["Content-Type"] = "text/html" if controller.response.code == 200
        response = Rack::Response.new(content, controller.response.code, {}.merge!(controller.response.headers))
      
        # Render (if response is 200) or redirect 
        # Set cookies        
        if controller.response.cookies != {}
          controller.response.cookies.each do |key, value|
            response.set_cookie(key, value)
          end
        end
        
        response.finish
      end
    rescue StandardError => err
      # OOPS!  Something broke.
      # Log it and send an error page...
      log_entry << "\t!!! [500] #{err}\n"
      log_entry << "*****"
      log_entry << err.backtrace.join("\n") + "\n\n"
      # content = @options[:errors] && @options[:errors][:internal_error] ? Renderer.send(@options[:templates].to_sym, File.open("#{@options[:path]}#{@options[:errors][:internal_error]}.#{@options[:templates]}", "r").read, context) : ErrorReporter.internal_error(err, @params)
      content = "error"
      [500, {"Content-Type" => "text/html"}, content]
    ensure
      # After every request push the buffered log entry out to the logger
      Log.enter log_entry.to_s + "\n"
    end
    
    # Inject the default helpers and helpers from the 
    # +helpers/+ directory (if available) into the 
    # RequestContext class.
    def include_helpers
      BaseController.send(:include, Fleet::Helpers)
    end
  end
end