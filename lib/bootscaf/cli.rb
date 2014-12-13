require 'thor'
module Bootscaf
  class CLI < Thor
    
    desc "version", "Ouputs the current version of Bootscaf"
    def version
      puts Bootscaf::VERSION
    end
    
  end
end