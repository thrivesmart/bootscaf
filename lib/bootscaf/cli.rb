require 'thor'
require 'net/http'

module Bootscaf
  class CLI < Thor
    YESSES = ['y', 'yes', 'Y', 'Yes', 'YES']
    LAST_KNOWN_BOOTSTRAP_VERSION = '3.3.1/'
    
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
        
        print "Checking for most recent bootstrap cdn version... "
        uri = URI.parse("https://raw.githubusercontent.com/MaxCDN/bootstrap-cdn/develop/public/twitter-bootstrap/latest")
        http = Net::HTTP.new(uri.host, uri.port); http.use_ssl = true
        latest_bootstrap_version = http.get(uri.request_uri).body
        print "#{latest_bootstrap_version}\n"
        latest_boostrap_version ||= LAST_KNOWN_BOOTSTRAP_VERSION
        
        print "Updating app/views/layouts/application.html.erb. "
        print `sed #{inplace_command} -e 's/<title>/<title><%= yield :page_title %>/' app/views/layouts/application.html.erb`
        print `sed #{inplace_command} -e "s/<%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>/<link href=\\"\\/\\/maxcdn.bootstrapcdn.com\\/bootstrap\\/#{latest_boostrap_version.gsub(/\//,'\\/')}css\\/bootstrap.min.css\\" rel=\\"stylesheet\\">\\\r\n<%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>/" app/views/layouts/application.html.erb`
        print `sed #{inplace_command} -e 's/<\\/head>/  <%= yield :after_css %>\\\r\n<\\/head>/' app/views/layouts/application.html.erb`
        print "\n"
      end
    end
    
  end
end