class Router
  attr_accessor :routes, :recognizer
  
  def initialize
    @routes = []
    @route_structure = {}
  end
  
  def add_route(route_string, *args)
    params = []
    args = (args.pop || {})
    request_method = args.delete(:method) || :GET
    
    requirements = args.delete(:requirements) || {}
    segments = route_string.split("/").map! do |segment|
      if segment =~ /:\w+/
        segment_symbol = segment[1..-1].to_sym
        params << segment_symbol
        requirements[segment_symbol] || ".*"
      else
        segment
      end
    end
    
    raise "Invalid route: Controller not specified" unless (params.include?(:controller) || args.keys.include?(:controller))
    
    new_route = Route.new(segments, params, request_method, args)
    @routes << new_route
    
    new_route.arguments[:controller] ||= :controller
    new_route.arguments[:action] ||= :action

    @route_structure[request_method] ||= {}
    @route_structure[request_method][new_route.arguments[:controller]] ||= {}
    @route_structure[request_method][new_route.arguments[:controller]][new_route.arguments[:action]] ||= [] 
    @route_structure[request_method][new_route.arguments[:controller]][new_route.arguments[:action]] << new_route
  end
  
  def recognize(path, request_method = :GET)
    @recognizer ||= build_recognizer
    
    matched = {}

    captures = @recognizer.match(path).captures[1..-1]
    if @routes[captures.index(captures.compact.last)]
      path_segments = path.gsub(/^\//, '').split("/")
      
      index = -1
      r.segments.each do |segment|                    
        next unless segment == "(.*)" || seg # FIXFXIFXIFXFIX
        index += 1
        
        matched[r.params[index]] = path_segments[index]
      end
      
      matched = r.arguments.merge(matched)
      matched[:action] = 'index' if matched[:action] == :action
    end
  end
  
  def generate(*args)
    params = args.pop
    request_method = params[:method].to_sym || :GET
    
    if params.keys.include?(:controller)
      controller_routes = @route_structure[:request_method][params[:controller]]
      
      unless controller_routes 
        controller_routes = @route_structure[:request_method][:controller]
      end
      
      action_routes = controller_routes[(params[:action] || 'index')] || controller_routes[:action]
      
      action_routes.each do |route|
        if (route.params - params.keys).empty?
          puts "generating from #{route.inspect}"
          return generate_url(route, params)
        else
          raise "No route to match that"
        end
      end
    else
      raise "No controller provided"
    end
  end
  
  def generate_url(route, params)
    route_string = route.segments.join("/")
    return route_string unless route_string.include?("(.*)")
    
    index = -1
    route_string.gsub!(/\(\.\*\)/) do |match|
      index += 1 
      params[route.params[index]]
    end
  end
  
  def route_resources(resources)
    resources = resources.to_s
    add_route resources, :controller => resources.to_sym, :action => 'index', :method => :GET
    add_route "#{resources}/:id", :controller => resources.to_sym, :action => 'show', :method => :GET
    add_route "#{resources}/new", :controller => resources.to_sym, :action => 'new', :method => :GET
    add_route "#{resources}/:id/edit", :controller => resources.to_sym, :action => 'edit', :method => :GET
    add_route "#{resources}/create", :controller => resources.to_sym, :action => 'create', :method => :POST
    add_route "#{resources}/:id/update", :controller => resources.to_sym, :action => 'update', :method => :PUT
    add_route "#{resources}/:id/destroy", :controller => resources.to_sym, :action => 'destroy', :method => :DELETE
  end
  
  def build_recognizer
    recognizers = []
    @routes.each do |route|
      recognizers << "(#{route.recognizer})"
    end
    
    @recognizer = /^(#{recognizers.join("|")})$/
  end
end

class Route
  attr_accessor :params, :segments, :arguments
  attr_reader :recognizer, :request_method
  
  def initialize(segment_list, param_list, request_method, argument_list = {})
    @segments = segment_list
    @params = param_list
    @arguments = argument_list || {}
    @recognizer = @segments.join("\/")
    @request_method = request_method
  end
end