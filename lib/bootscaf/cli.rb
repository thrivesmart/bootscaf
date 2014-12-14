require 'thor'
module Bootscaf
  class CLI < Thor
    YESSES = ['y', 'yes', 'Y', 'Yes', 'YES']
    LAST_KNOWN_BOOTSTRAP_VERSION = '3.3.1'
    
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
      if YESSES.include?(update_apphtml)
        latest_boostrap_version = LAST_KNOWN_BOOTSTRAP_VERSION
        
        print "Updating app/views/layouts/application.html.erb. "
        print `sed #{inplace_command} -e 's/<title>/<title><%= yield :page_title %>/' app/views/layouts/application.html.erb`
        print `sed #{inplace_command} -e 's/<%= stylesheet_link_tag    \\'application\\', media: \\'all\\', \\'data-turbolinks-track\\' => true %>/<link href="\\/\\/maxcdn.bootstrapcdn.com\\/bootstrap\\/#{latest_boostrap_version}\\/css\\/bootstrap.min.css" rel="stylesheet">\\n<%= stylesheet_link_tag    \\'application\\', media: \\'all\\', \\'data-turbolinks-track\\' => true %>/' app/views/layouts/application.html.erb`
        print "\n"
      end
    end
    
  end
end