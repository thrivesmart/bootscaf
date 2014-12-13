require 'thor'
module Bootscaf
  class CLI < Thor
    
    desc "version", "Ouputs the current version of Bootscaf"
    def version
      puts Bootscaf::VERSION
    end
    
    desc "update MODELNAME", "Updates the scaffold for the given MODELNAME (optionally, use --all)"
    option :all, :type => :boolean
    def update(modelname = nil)
      puts options[:all] ? "Running on all models scaffolds." : "Running on #{modelname} scaffolds." 
    end
    
  end
end