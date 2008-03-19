module Fleet
  # A class to render the default error pages.  These will
  # not render if error pages are specified in the configuration.
  class ErrorReporter
    # Standard template to render for a <tt>500 Internal Server Error</tt>
    def self.internal_error(error, params)
      """
      <html>
        <head>
          <title>Fleet Error: 500 Internal Server Error</title>
          <style>
            body { margin: 0px; padding: 0px; font-family: sans-serif; }
            h1 { background: #3E2B09; padding: 45px 10px 10px 10px; color: #6F5E3C;  border: 0px; border-bottom: 2px solid #1C0907; margin: 0px; }
            h1 span.error { text-shadow: 0.1em 0.1em #333; color: white; }
            h2 { margin: 0px; padding: 5px 5px 10px 10px; font-size: 14pt !important; }
            h2 span.where { color: #999; }
            h3 { margin: 0px; padding: 10px 10px; color: #999;}
            ul { margin: 0px; }
            li { margin: 0px; padding: 0px 30px; }
            pre { padding: 0 30px; margin: 0px; }
          </style>
        </head>

        <body>
          <h1><span class='error'>#{error.class}</span> 500 Internal Server Error</h1>
          <h2>#{error.message} <span class='where'>at #{error.backtrace[0]}</span></h2>
          <div>
            <h3>Parameters</h3>
            <ul>
              #{params == {} ? "None" : params.to_a.map{|key, val| "<li><b>" + key.to_s + "<b> = " + val.to_s + "</li>"}.join("\n") }
            </ul>
            <br />
            <h3>Backtrace</h3>
            <pre>#{error.backtrace.join("\n")}</pre>
          </div>
        </body>
      </html>
      
      """
    end
    
    # Standard template to render for a <tt>404 Page Not Found</tt> error
    def self.not_found(url, remote_ip, params)
      """
      <html>
        <head>
          <title>Fleet Error: 404 Page Not Found</title>
          <style>
            body { margin: 0px; padding: 0px; font-family: sans-serif; }
            h1 { background: #3E2B09; padding: 45px 10px 10px 10px; color: #6F5E3C;  border: 0px; border-bottom: 2px solid #1C0907; margin: 0px; }
            h1 span.error { text-shadow: 0.1em 0.1em #333; color: white; }
            h2 { margin: 0px; padding: 5px 5px 10px 10px; font-size: 14pt !important; }
            h2 span.where { color: #999; }
            h3 { margin: 0px; padding: 10px 10px; color: #999;}
            ul { margin: 0px; }
            li { margin: 0px; padding: 0px 30px; }
            pre { padding: 0 30px; margin: 0px; }
          </style>
        </head>

        <body>
          <h1><span class='error'>Page Not Found</span> 404 Not Found</h1>
          <h2>Request for #{url} <span class='where'>from #{remote_ip}</span></h2>
          <div>
            <h3>Parameters</h3>
            <ul>
              #{params == {} ? "None" : params.to_a.map{|key, val| "<li><b>" + key.to_s + "<b> = " + val.to_s + "</li>"}.join("\n") }
            </ul>
          </div>
        </body>
      </html>
      
      """
    end
  end
end