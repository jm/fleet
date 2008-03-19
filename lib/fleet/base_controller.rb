require 'rack'
require 'rack/file'

module Fleet
  module ApplicationSpace
  end
  
  # Class that encapsulates the response's headers and
  # response code.
  class Response
    attr_accessor :headers, :code, :cookies
  
    def initialize
      self.headers = {}
      self.code = 200
      self.cookies = {}
    end
  end

  # A class that creates a context for template
  # rendering.  Helpers are mixed in here to give
  # templates access to them.
  class BaseController
    attr_accessor :request, :response
  
    def initialize(incoming_request, action)
      self.request = incoming_request
      self.response = Fleet::Response.new
      
      self.request.instance_variable_set :@controller, self.class.to_s.demodulize.underscore
      self.request.instance_variable_set :@action, action
    end
    
    def cookies
      self.request.cookies
    end
    
    def set_cookie(key, val)
      self.response.cookies[key] = val
    end
    
    def render(template = "#{self.request.controller}/#{self.request.action}")
      Renderer.send("erb", File.open("app/views/#{template}.erb", "r").read, self)
    end
  end
end

module Rack
  class Request
    attr_reader :action, :controller
    
    def remote_ip
      @env['REMOTE_ADDR']
    end
    
    def user_agent
      @env['HTTP_USER_AGENT']
    end
  end
end