require 'thor'
module Bootscaf
  class CLI < Thor
    
    desc "verzion", "Ouputs the current version of Bootscaf"
    def verzion
      puts Bootscaf::VERSION
    end
    
  end
end