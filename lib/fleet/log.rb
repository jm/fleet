require 'logger'

module Fleet
  # Class to handle logging to a file and to
  # the console.
  class Log
    # Method to log something.
    def self.enter(text = "", level = :debug)
      @@console ||= Logger.new(STDOUT)
      @@file ||= Logger.new('requests.log')
  
      @@console.send(level, text)
      @@file.send(level, text)
    end
  end
end