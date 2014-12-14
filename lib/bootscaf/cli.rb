require 'thor'
module Bootscaf
  class CLI < Thor
    YESSES = ['y', 'yes', 'Y', 'Yes', 'YES']
    
    desc "version", "Ouputs the current version of Bootscaf"
    def version
      puts Bootscaf::VERSION
    end
    
    desc "update MODELNAME", "Updates the scaffold for the given MODELNAME (optionally, use --all)"
    option :all, :type => :boolean
    def update(modelname = nil)
      puts options[:all] ? "Running on all models scaffolds." : "Running on #{modelname} scaffolds." 
      
      is_mac = (RbConfig::CONFIG['host_os'] =~ /^darwin/) >= 0
      inplace_command = is_mac ? "-i ''" : '--in-place'
      
      print "Would you like to update app/views/layouts/application.html.erb [y/n(default)]? "
      update_apphtml = $stdin.gets.strip
      print "YOU SAID `#{update_apphtml}`"
      if YESSES.include?(update_apphtml)
        print "Updating app/views/layouts/application.html.erb... "
        print `sed #{inplace_command} -e 's/<title>/<title><%= yield :page_title %> /' app/views/layouts/application.html.erb`
      end
    end
    
  end
end