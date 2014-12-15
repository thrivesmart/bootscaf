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
        print `sed #{inplace_command} -e "s/<%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>/<link href=\\"\\/\\/maxcdn.bootstrapcdn.com\\/bootstrap\\/#{latest_boostrap_version.gsub(/\//,'\\/')}css\\/bootstrap.min.css\\" rel=\\"stylesheet\\">\\\n<%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>/" app/views/layouts/application.html.erb`
        print `sed #{inplace_command} -e "s/<%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>/\\\n/" app/views/layouts/application.html.erb`
        print `sed #{inplace_command} -e 's/<\\/head>/  <%= yield :after_css %>\\\n<\\/head>/' app/views/layouts/application.html.erb`
        print `sed #{inplace_command} -e 's/<body>/<body class="controller-<%= controller.controller_name.dasherize %> action-<%= controller.action_name.dasherize %>">  <nav class="navbar navbar-default navbar-inverse" role="navigation">\\\n    <div class="container">\\\n      <div class="navbar-header">\\\n        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">\\\n          <span class="sr-only">Toggle navigation<\\/span>\\\n          <span class="icon-bar"><\\/span>\\\n          <span class="icon-bar"><\\/span>\\\n          <span class="icon-bar"><\\/span>\\\n        <\\/button>\\\n        <a class="navbar-brand" href="\\/">Foo<\\/a>\\\n      <\\/div>\\\n      <div id="navbar" class="navbar-collapse collapse">\\\n        <ul class="nav navbar-nav">\\\n          <li<%= request.path == "\\/" ? " class=\\\\"active\\\\"".html_safe : "" %>><a href="\\/">Home<\\/a><\\/li>\\\n        <\\/ul> \\\n        <ul class="nav navbar-nav navbar-right">\\\n          <li class="bar"><a href="\\/">Bar<\\/a><\\/li>\\\n        <\\/ul>\\\n      <\\/div>\\\n    <\\/div>\\\n  <\\/nav>\\\n  <% unless notice.blank? %>\\\n    <div id="notice" class="alert alert-success" role="alert">\\\n      <div class="container">\\\n        <%= notice %>\\\n      <\\/div>\\\n    <\\/div>\\\n  <% end %>/' app/views/layouts/application.html.erb`
        print `sed #{inplace_command} -e 's/<%= yield %>/<%= yield %>\\\n    <footer id="content-footer" role="contentinfo">\\\n      <div class="container">\\\n        <p class="align-center">\\\n          Copyright &copy; <%= Time.now.year %> Foo · all rights reserved.\\\n        <\\/p>\\\n      <\\/div>\\\n    <\\/footer>\\\n\\\n    <%= yield :before_js %>\\\n    <% unless ENV["GOOGLE_ANALYTICS_ID"].blank? %>\\\n    <script>\\\n      (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){\\\n      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\\\n      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\\\n      })(window,document,'script','\\/\\/www.google-analytics.com\\/analytics.js','ga');\\\n      ga("create", "<%= ENV["GOOGLE_ANALYTICS_ID"] %>", "auto");\\\n      ga("send", "pageview");\\\n    <\\/script>\\\n    <% end %>\\\n    <script src="\\/\\/code.jquery.com\\/jquery-2.1.1.min.js"><\\/script>\\\n    <script src="\\/\\/code.jquery.com\\/ui\\/1.11.2\\/jquery-ui.min.js"><\\/script>\\\n    <script src="\\/\\/maxcdn.bootstrapcdn.com\\/bootstrap\\/3.3.1\\/js\\/bootstrap.min.js"><\\/script>\\\n    <%= javascript_include_tag "application", "data-turbolinks-track" => true %>\\\n    <%= yield :after_js %>",\\\n  /' app/views/layouts/application.html.erb`
        print "\n"
      end
    end
    
  end
end