module Fleet
  # A module of various helpers, many of them copied or based on Rails helpers.
  module Helpers
    # Borrowed from Rails, a regex to pick out things to link in text
    AUTO_LINK_RE = %r{
                    (                          # leading text
                      <\w+.*?>|                # leading HTML tag, or
                      [^=!:'"/]|               # leading punctuation, or 
                      ^                        # beginning of line
                    )
                    (
                      (?:https?://)|           # protocol spec, or
                      (?:www\.)                # www.*
                    ) 
                    (
                      [-\w]+                   # subdomain or domain
                      (?:\.[-\w]+)*            # remaining subdomains or domain
                      (?::\d+)?                # port
                      (?:/(?:(?:[~\w\+@%-]|(?:[,.;:][^\s$]))+)?)* # path
                      (?:\?[\w\+@%&=.;-]+)?     # query string
                      (?:\#[\w\-]*)?           # trailing anchor
                    )
                    ([[:punct:]]|\s|<|$)       # trailing text
                   }x unless const_defined?(:AUTO_LINK_RE)
    
    # Redirect to a URL or other action using a 301 status code
    # and +Location+ header.
    def redirect_to(url)
      response.code = 301
      response.headers['Location'] = url
    end
    
    # Link to a given +url+ with the given +text+.
    def link_to(text, url)
      "<a href='#{url}' title='#{text}'>#{text}</a>"
    end
    
    # Auto link URLs and e-mail addresses in +text+.
    def auto_link(text)
      auto_link_email_addresses(auto_link_urls(text))
    end
    
    # Auto link e-mail addresses in +text+.
    def auto_link_email_addresses(text)
      body = text.dup
      text.gsub(/([\w\.!#\$%\-+.]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)+)/) do
        text = $1
          
        if body.match(/<a\b[^>]*>(.*)(#{Regexp.escape(text)})(.*)<\/a>/)
          text
        else
          %{<a href="mailto:#{text}">#{text}</a>}
        end
      end
    end
    
    # Auto link URLs in +text.
    def auto_link_urls(text)
      text.gsub(AUTO_LINK_RE) do
        all, a, b, c, d = $&, $1, $2, $3, $4
    
        if a =~ /<a\s/i # don't replace URL's that are already linked
          all
        else
          text = b + c
          %(#{a}<a href="#{b=="www."?"http://www.":b}#{c}">#{text}</a>#{d})
        end
      end
    end
  
    # Grab an excerpt from +text+, starting at +start+ and stopping at +stop+.
    # The +padding+ argument lets you define what should be on eithe side of the
    # excerpt.
    def excerpt(text, start = 0, stop = 20, padding = "...")
      return "" if text.nil?
      
      (padding if start > 0).to_s + text[start..(start + stop)] + padding
    end
  
    # Highlight an array of +phrases+ in +text+.  The +highlighter+ argument lets you set 
    # how to highlight the text.
    def highlight(text, phrases, highlighter = '<strong class="highlight">\1</strong>')
      if text.blank? || phrases.blank?
        text
      else
        match = Array(phrases).map { |p| Regexp.escape(p) }.join('|')
        text.gsub(/(#{match})/i, highlighter)
      end
    end
  
    # Truncate +text+ to the length specified in +length+ with +ending+ 
    # as the text appearing on the end.
    def truncate(text, length = 20, ending = "...")
      return "" if text.nil?
      
      text[0..length] + ending
    end
  
    # Create a button that submits to another URL.
    def button_to(url, text = "Click Here")
      "<form method='GET' action='#{url}'><div class='button-to'><input type='submit' value='#{text}'></div></form>"
    end
  
    # Create a +mailto:+ link for +address+.  You can optionally provide
    # +text+ for the link's text.
    def mail_to(address, text = nil)
      "<a href='mailto:#{address}'>#{text || address}</a>"
    end
  end
end