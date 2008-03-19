%w{ erubis redcloth bluecloth markaby haml }.each do |engine|
  begin
    require engine
  rescue LoadError
    next
  end
end

module Fleet
  # Core rendering class.
  class Renderer
    # Render an ERb template.  Uses Erubis if available
    # and if not, falls back to standard ERb.
    def self.erb(template, request)
      if Erubis
        Erubis::Eruby.new(template).evaluate(request)
      else
        ERB.new(template).result(request.send(:binding))
      end
    end
    
    # Render a HAML template.
    def self.haml(template, request)
      if Haml
        Haml::Engine.new(template).render(request)
      else
        raise "You don't have Haml installed!"
      end
    end
    
    # Render a Markaby template.
    def self.mab(template, request)
      if Markaby
        Markaby::Builder.new.instance_eval(template).to_s
      else
        raise "You don't have Markaby installed!"
      end
    end
    
  end
end