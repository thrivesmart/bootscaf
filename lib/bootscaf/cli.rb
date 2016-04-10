# encoding: utf-8
require 'thor'
require 'net/http'
require_relative 'utils.rb'
require_relative 'version.rb'

module Bootscaf
  class CLI < Thor
    YESSES = ['y', 'yes', 'Y', 'Yes', 'YES']
    NOS = ['n', 'no', 'N', 'No', 'NO']
    LAST_KNOWN_BOOTSTRAP_VERSION = '3.3.5/'
    LAST_KNOWN_JQUERY_VERSION = '2.1.4'
    LAST_KNOWN_JQUERY_UI_VERSION = '1.11.4'
    
    desc "version", "Ouputs the current version of Bootscaf"
    def version
      puts Bootscaf::VERSION
    end
    
    desc "nest PLURALMODELNAME:PLURALMODELNAME[:PLURALMODELNAME...]", "Updates the scaffold controller and views to nest the models"
    def nest(nestpath)
      
      darwin_match = (RbConfig::CONFIG['host_os'] =~ /^darwin/)
      is_mac = !darwin_match.nil? && darwin_match >= 0
      icmd = is_mac ? "-i ''" : '--in-place'
      
      fullpath = nestpath.split(':').map { |a| a.downcase }
      ancestors_only = fullpath.first(fullpath.size-1)
      singularized_ancestors = ancestors_only.map {|a| Bootscaf::Utils.singularize(a) }
      modelname = fullpath.last
      singular_modelname = Bootscaf::Utils.singularize(modelname)
      
      print "Running on #{modelname} scaffolds with nesting path `#{singularized_ancestors.join(' > ')}`.\n"
      
      print "Updating app/controllers/#{modelname}_controller.rb.\n"
      singularized_ancestors.reverse.each do |sa|
        print `sed #{icmd} -e 's/Controller < ApplicationController/Controller < ApplicationController\\\nbefore_action :set_#{sa}/' app/controllers/#{modelname}_controller.rb`
      end
      singularized_ancestors.each_with_index do |sa, idx|
        if idx == 0
          print `sed #{icmd} -e 's/private/private\\\n\\\ndef set_#{sa}\\\n@#{sa} = #{sa.capitalize}.find_by_id(params[:#{sa}_id])\\\nraise ActiveRecord::RecordNotFound unless @#{sa}\\\nend\\\n/' app/controllers/#{modelname}_controller.rb`
        else
          print `sed #{icmd} -e 's/private/private\\\n\\\ndef set_#{sa}\\\n@#{sa} = @#{singularized_ancestors[idx-1]}.#{ancestors_only[idx]}.find_by_id(params[:#{sa}_id])\\\nraise ActiveRecord::RecordNotFound unless @#{sa}\\\nend\\\n/' app/controllers/#{modelname}_controller.rb`
        end
        print `sed #{icmd} -e 's/.permit(\\(.*\\):#{sa}_id, \\(.*\\))/.permit(\\1\\2)/' app/controllers/#{modelname}_controller.rb`
      end
      print `sed #{icmd} -e 's/#{singular_modelname.capitalize}.all/@#{singularized_ancestors.last}.#{modelname}.all/' app/controllers/#{modelname}_controller.rb`
      print `sed #{icmd} -e 's/#{singular_modelname.capitalize}.new/@#{singularized_ancestors.last}.#{modelname}.build/' app/controllers/#{modelname}_controller.rb`
      print `sed #{icmd} -e 's/redirect_to @#{singular_modelname},/redirect_to [@#{singularized_ancestors.join(', @')}, @#{singular_modelname}],/' app/controllers/#{modelname}_controller.rb`
      print `sed #{icmd} -e 's/, location: @#{singular_modelname}/, location: [@#{singularized_ancestors.join(', @')}, @#{singular_modelname}]/' app/controllers/#{modelname}_controller.rb`
      print `sed #{icmd} -e 's/redirect_to #{modelname}_url/redirect_to [#{singularized_ancestors.map{|sa| "@#{sa}"}.join(', ')}, :#{modelname}]/' app/controllers/#{modelname}_controller.rb`
      print `sed #{icmd} -e 's/#{singular_modelname.capitalize}.find(params\\[:id\\])/@#{singularized_ancestors.last}.#{modelname}.find(params[:id])/' app/controllers/#{modelname}_controller.rb`
      
      print "Updating app/views/#{modelname}/_form.html.erb.\n"
      print `sed #{icmd} -e 's/form_for(@#{singular_modelname})/form_for([@#{singularized_ancestors.join(', @')}, @#{singular_modelname}])/' app/views/#{modelname}/_form.html.erb`
      
      print "Updating app/views/#{modelname}/edit.html.erb.\n"
      print `sed #{icmd} -e 's/Edit \\(.*\\) - $/Edit \\1 - #{singularized_ancestors.last.to_s.capitalize} <%= @#{singularized_ancestors.last}.id %>/' app/views/#{modelname}/edit.html.erb`
      print `sed #{icmd} -e 's/<h1>Editing \\(.*\\)<\\/h1>/<h1>Editing \\1 <small>#{singularized_ancestors.last.capitalize} <%= @#{singularized_ancestors.last}.id %><\\/small><\\/h1>/' app/views/#{modelname}/edit.html.erb`
      print `sed #{icmd} -e 's/.html_safe, @#{singular_modelname}, class:/.html_safe, [@#{singularized_ancestors.join(', @')}, @#{singular_modelname}], class:/' app/views/#{modelname}/edit.html.erb`
      print `sed #{icmd} -e 's/.html_safe, @#{singular_modelname}, method:/.html_safe, [@#{singularized_ancestors.join(', @')}, @#{singular_modelname}], method:/' app/views/#{modelname}/edit.html.erb`
    
      print "Updating app/views/#{modelname}/index.html.erb.\n"
      print `sed #{icmd} -e 's/#{modelname.capitalize} - $/#{modelname.capitalize} - #{singularized_ancestors.last.capitalize} <%= @#{singularized_ancestors.last}.id %>/' app/views/#{modelname}/index.html.erb`
      print `sed #{icmd} -e 's/.html_safe, "\\/", /.html_safe, [#{singularized_ancestors.map{|sa| "@#{sa}"}.join(', ')}], /' app/views/#{modelname}/index.html.erb`
      print `sed #{icmd} -e 's/.html_safe, \\[:new, :#{singular_modelname}\\], /.html_safe, [:new, #{singularized_ancestors.map{|sa| "@#{sa}"}.join(', ')}, :#{singular_modelname}], /' app/views/#{modelname}/index.html.erb`
      print `sed #{icmd} -e 's/Listing #{modelname.capitalize}$/Listing #{modelname.capitalize}\\\n  <small>#{singularized_ancestors.last.capitalize} <%= @#{singularized_ancestors.last}.id %><\\/small>/' app/views/#{modelname}/index.html.erb`
      print `sed #{icmd} -e 's/data-href="<%= #{singular_modelname}_path(#{singular_modelname}) %>"/data-href="<%= polymorphic_path([#{singularized_ancestors.map{|sa| "@#{sa}"}.join(', ')}, #{singular_modelname}]) %>"/' app/views/#{modelname}/index.html.erb`
      print `sed #{icmd} -e 's/, #{singular_modelname} %><\\/td>/, [#{singularized_ancestors.map{|sa| "@#{sa}"}.join(', ')}, #{singular_modelname}] %><\\/td>/' app/views/#{modelname}/index.html.erb`
    
      print "Updating app/views/#{modelname}/index.json.jbuilder.\n"
      print `sed #{icmd} -e 's/#{singular_modelname}_url(#{singular_modelname}, format: :json)/polymorphic_url([#{singularized_ancestors.map{|sa| "@#{sa}"}.join(', ')}, #{singular_modelname}], format: :json)/' app/views/#{modelname}/index.json.jbuilder`
      
      print "Updating app/views/#{modelname}/new.html.erb.\n"
      print `sed #{icmd} -e 's/Create #{singular_modelname.capitalize} - $/Create #{singular_modelname.capitalize} - #{singularized_ancestors.last.capitalize} <%= @#{singularized_ancestors.last}.id %>/' app/views/#{modelname}/new.html.erb`
      print `sed #{icmd} -e 's/New #{singular_modelname.capitalize}$/New #{singular_modelname.capitalize} <small>#{singularized_ancestors.last.capitalize} <%= @#{singularized_ancestors.last}.id %><\\/small>/' app/views/#{modelname}/new.html.erb`
      print `sed #{icmd} -e 's/, #{modelname}_path, /, polymorphic_path([#{singularized_ancestors.map{|sa| "@#{sa}"}.join(', ')}, :#{modelname}]), /' app/views/#{modelname}/new.html.erb`
      
      print "Updating app/views/#{modelname}/show.html.erb.\n"
      print `sed #{icmd} -e 's/#{singular_modelname.capitalize} Details - $/#{singular_modelname.capitalize} Details - #{singularized_ancestors.last.capitalize} <%= @#{singularized_ancestors.last}.id %>/' app/views/#{modelname}/show.html.erb`
      print `sed #{icmd} -e 's/ #{modelname}_path,/ polymorphic_path([#{singularized_ancestors.map{|sa| "@#{sa}"}.join(', ')}, :#{modelname}]),/' app/views/#{modelname}/show.html.erb`
      print `sed #{icmd} -e 's/edit_#{singular_modelname}_path(@#{singular_modelname})/polymorphic_path([:edit, #{singularized_ancestors.map{|sa| "@#{sa}"}.join(', ')}, @#{singular_modelname}])/' app/views/#{modelname}/show.html.erb`
      print `sed #{icmd} -e 's/#{singular_modelname.capitalize} Details$/#{singular_modelname.capitalize} Details <small>#{singularized_ancestors.last.capitalize} <%= @#{singularized_ancestors.last}.id %><\\/small>/' app/views/#{modelname}/show.html.erb`
      
    end
    
    desc "update PLURALMODELNAME", "Updates the scaffold for the given PLURALMODELNAME (optionally, use --all)"
    option :all, :type => :boolean
    def update(modelname = nil)
      puts options[:all] ? "Running on *all* models scaffolds." : "Running on #{modelname} scaffolds." 
      
      models = options[:all] ? [] : [ modelname ]
      if options[:all]
        models = Dir.glob("#{Dir.pwd}/app/views/*").select { |f| File.directory? f }.map { |f| f.split('/app/views/').last }.reject { |f| f == 'layouts' }
      end
      
      darwin_match = (RbConfig::CONFIG['host_os'] =~ /^darwin/)
      is_mac = !darwin_match.nil? && darwin_match >= 0
      icmd = is_mac ? "-i ''" : '--in-place'
      
      print "Would you like to update app/views/layouts/application.html.erb [y/n(default)]? "
      update_apphtml = $stdin.gets.strip
      if YESSES.include?(update_apphtml)
        
        print "Checking for most recent bootstrap cdn version... "
        uri = URI.parse("https://raw.githubusercontent.com/MaxCDN/bootstrap-cdn/develop/public/twitter-bootstrap/latest")
        http = Net::HTTP.new(uri.host, uri.port); http.use_ssl = true
        latest_bootstrap_version = http.get(uri.request_uri).body
        latest_bootstrap_version.each_line { |line| }
        print "#{latest_bootstrap_version}\n"
        latest_boostrap_version ||= LAST_KNOWN_BOOTSTRAP_VERSION
        
        
        print "Checking for most recent jquery cdn version... "
        uri = URI.parse("http://code.jquery.com/")
        http = Net::HTTP.new(uri.host, uri.port)
        http_body = http.get(uri.request_uri).body
        minor_version = /<a .* href='\/jquery\-2\.(.*?)\.min\.js' .*>minified<\/a>/.match(http_body)[1]
        latest_jquery_version = "2.#{minor_version}"
        print "#{latest_jquery_version}\n"
        latest_boostrap_version ||= LAST_KNOWN_BOOTSTRAP_VERSION
        
        print "Checking for most recent jquery-ui version... "
        minor_version = /<a .* href='\/ui\/(.*?)\/jquery-ui.min.js' .*>minified<\/a>/.match(http_body)[1]
        latest_jquery_ui_version = "#{minor_version}"
        print "#{latest_jquery_ui_version}\n"
        latest_jquery_ui_version ||= LAST_KNOWN_JQUERY_UI_VERSION
        
        print "Updating app/views/layouts/application.html.erb. "
        print `sed #{icmd} -e 's/<title>/<title><%= yield :page_title %>/' app/views/layouts/application.html.erb`
        print `sed #{icmd} -e "s/<%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>/<link href=\\"\\/\\/maxcdn.bootstrapcdn.com\\/bootstrap\\/#{latest_boostrap_version.gsub(/\//,'\\/')}css\\/bootstrap.min.css\\" rel=\\"stylesheet\\">\\\n<%= stylesheet_link_tag    'application', media: 'all', 'data-turbolinks-track' => true %>/" app/views/layouts/application.html.erb`
        print `sed #{icmd} -e "s/<%= javascript_include_tag 'application', 'data-turbolinks-track' => true %>/\\\n/" app/views/layouts/application.html.erb`
        print `sed #{icmd} -e 's/<\\/head>/  <%= yield :after_css %>\\\n<\\/head>/' app/views/layouts/application.html.erb`
        print `sed #{icmd} -e 's/<body>/<body class="controller-<%= controller.controller_name.dasherize %> action-<%= controller.action_name.dasherize %>">  <nav class="navbar navbar-default navbar-inverse" role="navigation">\\\n    <div class="container">\\\n      <div class="navbar-header">\\\n        <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">\\\n          <span class="sr-only">Toggle navigation<\\/span>\\\n          <span class="icon-bar"><\\/span>\\\n          <span class="icon-bar"><\\/span>\\\n          <span class="icon-bar"><\\/span>\\\n        <\\/button>\\\n        <a class="navbar-brand" href="\\/">Foo<\\/a>\\\n      <\\/div>\\\n      <div id="navbar" class="navbar-collapse collapse">\\\n        <ul class="nav navbar-nav">\\\n          <li<%= request.path == "\\/" ? " class=\\\\"active\\\\"".html_safe : "" %>><a href="\\/">Home<\\/a><\\/li>\\\n        <\\/ul> \\\n        <ul class="nav navbar-nav navbar-right">\\\n          <li class="bar"><a href="\\/">Bar<\\/a><\\/li>\\\n        <\\/ul>\\\n      <\\/div>\\\n    <\\/div>\\\n  <\\/nav>\\\n  <% unless notice.blank? %>\\\n    <div id="notice" class="alert alert-success" role="alert">\\\n      <div class="container">\\\n        <%= notice %>\\\n      <\\/div>\\\n    <\\/div>\\\n  <% end %>/' app/views/layouts/application.html.erb`
        print `sed #{icmd} -e 's/<%= yield %>/<%= yield %>\\\n    <footer id="content-footer" role="contentinfo">\\\n      <div class="container">\\\n        <p class="align-center">\\\n          Copyright \\&copy; <%= Time.now.year %> Foo · all rights reserved.\\\n        <\\/p>\\\n      <\\/div>\\\n    <\\/footer>\\\n\\\n    <%= yield :before_js %>\\\n    <% unless ENV["GOOGLE_ANALYTICS_ID"].blank? %>\\\n    <script>\\\n      (function(i,s,o,g,r,a,m){i["GoogleAnalyticsObject"]=r;i[r]=i[r]||function(){\\\n      (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),\\\n      m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)\\\n      })(window,document,"script","\\/\\/www.google-analytics.com\\/analytics.js","ga");\\\n      ga("create", "<%= ENV["GOOGLE_ANALYTICS_ID"] %>", "auto");\\\n      ga("send", "pageview");\\\n    <\\/script>\\\n    <% end %>\\\n    <script src="\\/\\/code.jquery.com\\/jquery-#{latest_jquery_version}.min.js"><\\/script>\\\n    <script src="\\/\\/code.jquery.com\\/ui\\/#{latest_jquery_ui_version}\\/jquery-ui.min.js"><\\/script>\\\n    <script src="\\/\\/maxcdn.bootstrapcdn.com\\/bootstrap\\/#{latest_boostrap_version.gsub(/\//,'\\/')}js\\/bootstrap.min.js"><\\/script>\\\n    <%= javascript_include_tag "application", "data-turbolinks-track" => true %>\\\n<%= yield :after_js %>\\\n/' app/views/layouts/application.html.erb`
        print "\n"
        
        print "Removing '//= require jquery' from app/assets/javascripts/application.js "
        print `sed #{icmd} -e 's/\\/\\/= require jquery$//' app/assets/javascripts/application.js`
        print "\n"
      end
    
      print "Would you like to overwrite scaffolds.scss with the bootrapified version [y/n(default)]? "
      use_scaffolds_css = $stdin.gets.strip
      if YESSES.include?(use_scaffolds_css)
        FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/../../assets/stylesheets/scaffolds.scss", "#{Dir.pwd}/app/assets/stylesheets"
        print "Wrote assets/stylesheets/scaffolds.scss\n"
      end
    
      print "Would you like to use tablesorter [y(default)/n]? "
      use_tablesorter = $stdin.gets.strip
      unless NOS.include?(use_tablesorter)
        uri = URI.parse('https://raw.githubusercontent.com/christianbach/tablesorter/master/jquery.tablesorter.js')
        http = Net::HTTP.new(uri.host, uri.port); http.use_ssl = true
        http_body = http.get(uri.request_uri).body
        written = File.open("#{Dir.pwd}/app/assets/javascripts/jquery.tablesorter.js", 'w') { |file| file.write(http_body) }
        print "Wrote #{written} - app/assets/javascripts/jquery.tablesorter.js\n"
        
        tablesorter_init_body = "$('table.tablesorter').tablesorter();\n"
        written = File.open("#{Dir.pwd}/app/assets/javascripts/jquery.tablesorterinit.js", 'w') { |file| file.write(tablesorter_init_body) }
        print "Wrote #{written} - app/assets/javascripts/jquery.tablesorterinit.js\n"
        
        FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/../../assets/images/tablesorter-down.png", "#{Dir.pwd}/app/assets/images"
        print "Wrote assets/images/tablesorter-down.png\n"
        FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/../../assets/images/tablesorter-up.png", "#{Dir.pwd}/app/assets/images"
        print "Wrote assets/images/tablesorter-up.png\n"
        FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/../../assets/images/tablesorter.png", "#{Dir.pwd}/app/assets/images"
        print "Wrote assets/images/tablesorter.png\n"
        
        FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/../../assets/stylesheets/tablesorter.scss", "#{Dir.pwd}/app/assets/stylesheets"
        print "Wrote assets/stylesheets/tablesorter.scss\n"
      end
    
      print "Would you like to make entire index.html.erb table rows clickable [y(default)/n]? "
      use_clickable_rows = $stdin.gets.strip
      unless NOS.include?(use_clickable_rows)
        linkedrow_init_body = "$(\".linked-row\").click(function() { window.document.location = $(this).attr(\"data-href\"); });\n"
        written = File.open("#{Dir.pwd}/app/assets/javascripts/table-linked-row.js", 'w') { |file| file.write(linkedrow_init_body) }
        print "Wrote #{written} - app/assets/javascripts/table-linked-row.js\n"
        
        FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/../../assets/stylesheets/table-linked-row.scss", "#{Dir.pwd}/app/assets/stylesheets"
        print "Wrote assets/stylesheets/table-linked-row.scss\n"
      end
    
      print "Would you like to add a 'click to select-all' input element [y(default)/n]? "
      use_click_to_selectall = $stdin.gets.strip
      unless NOS.include?(use_click_to_selectall)
        selectall_init_body = "$('.select-all-on-click').click(function () { this.select(); });\n"
        written = File.open("#{Dir.pwd}/app/assets/javascripts/select-all-on-click.js", 'w') { |file| file.write(selectall_init_body) }
        print "Wrote #{written} - app/assets/javascripts/select-all-on-click.js\n"
        
        FileUtils.cp "#{File.expand_path(File.dirname(__FILE__))}/../../assets/stylesheets/select-all-on-click.scss", "#{Dir.pwd}/app/assets/stylesheets"
        print "Wrote assets/stylesheets/select-all-on-click.scss\n"
      end
      
      models.each do |modelname|
        singular_modelname = Bootscaf::Utils.singularize(modelname)
        
        print "\n\nWorking on model:#{modelname}\n\n"
        
        print "Updating app/views/#{modelname}/_form.html.erb. "
        print `sed #{icmd} -e 's/<div id="error_explanation">/<div id="error_explanation" class="alert alert-danger" role="alert">/' app/views/#{modelname}/_form.html.erb`
        print `sed #{icmd} -e 's/<h2>/<strong>/' app/views/#{modelname}/_form.html.erb`
        print `sed #{icmd} -e 's/<\\/h2>/<\\/strong>/' app/views/#{modelname}/_form.html.erb`
        print `sed #{icmd} -e 's/<div class="field">/<div class="row">/g' app/views/#{modelname}/_form.html.erb`
        print `sed #{icmd} -e 's/<%= f.label :\\(.*\\) %><br>/<div class="form-group<%= f.object.errors[:\\1].empty? ? "" : " has-error has-feedback" %>">\\\n<%= f.label :\\1, { class: "control-label col-sm-2" } %>\\\n<div class="col-sm-10">/g' app/views/#{modelname}/_form.html.erb`
        print `sed #{icmd} -e 's/<%= f.\\(.*\\)_field :\\(.*\\) %>/<%= f.\\1_field :\\2, { class: "form-control" } %>\\\n<\\/div>\\\n<\\/div>/g' app/views/#{modelname}/_form.html.erb`
        print `sed #{icmd} -e 's/<%= f.\\(.*\\)_area :\\(.*\\) %>/<%= f.\\1_area :\\2, { class: "form-control" } %>\\\n<\\/div>\\\n<\\/div>/g' app/views/#{modelname}/_form.html.erb`
        print `sed #{icmd} -e 's/<%= f.\\(.*\\)_box :\\(.*\\) %>/<%= f.\\1_box :\\2, { class: "form-control" } %>\\\n<\\/div>\\\n<\\/div>/g' app/views/#{modelname}/_form.html.erb`
        print `sed #{icmd} -e 's/<%= f.\\(.*\\)_select :\\(.*\\) %>/<%= f.\\1_select :\\2, { class: "form-control" } %>\\\n<\\/div>\\\n<\\/div>/g' app/views/#{modelname}/_form.html.erb`
        print `sed #{icmd} -e 's/<div class="actions">/<div class="actions text-center">/' app/views/#{modelname}/_form.html.erb`
        print `sed #{icmd} -e 's/<%= f.submit %>/<%= f.submit class: "btn btn-success" %>/' app/views/#{modelname}/_form.html.erb`
        print "\n"
        
        print "Updating app/views/#{modelname}/edit.html.erb. "
        print `sed #{icmd} -e 's/<h1>Editing \\(.*\\)<\\/h1>/<% content_for :page_title do %>\\\nEdit \\1 - \\\n<% end %>\\\n<div class="container">\\\n<div class="page-header">\\\n<h1>Editing \\1<\\/h1>\\\n<\\/div>/' app/views/#{modelname}/edit.html.erb`
        print `sed #{icmd} -e 's/<%= link_to '\\''Show'\\'', @#{singular_modelname} %> \\|/<div class="clearfix"><\\/div>\\\n<div class="pull-left">\\\n<%= link_to "<span class=\\\\"glyphicon glyphicon-ban-circle\\\\" aria-hidden=\\\\"true\\\\"><\\/span> Cancel".html_safe, @#{singular_modelname}, class: "btn btn-default" %>\\\n<\\/div>/' app/views/#{modelname}/edit.html.erb`
        print `sed #{icmd} -e 's/<%= link_to '\\''Back'\\'', #{modelname}_path %>/<div class="pull-right">\\\n<%= link_to "<span class=\\\\"glyphicon glyphicon-trash\\\\" aria-hidden=\\\\"true\\\\"><\\/span> Delete #{singular_modelname}...".html_safe, @#{singular_modelname}, method: :delete, data: { confirm: "Are you sure you want to delete this #{singular_modelname}?" }, class: "btn btn-danger" %>\\\n<\\/div>\\\n<\\/div>/' app/views/#{modelname}/edit.html.erb`  
        print "\n"
                
        print "Updating app/views/#{modelname}/index.html.erb. "
        print `sed #{icmd} -e 's/<p id="notice"><%= notice %><\\/p>//' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<h1>Listing \\(.*\\)s<\\/h1>/<% content_for :page_title do %>\\\n\\1s - \\\n<% end %>\\\n<div class="container">\\\n<div class="page-header">\\\n<h1>\\\n<div class="pull-left">\\\n<%= link_to "<span class=\\\\"glyphicon glyphicon-step-backward\\\\" aria-hidden=\\\\"true\\\\"><\\/span>".html_safe, "\\/", class: "btn btn-default", title: "Back" %>\\\n\\&nbsp;\\\n<\\/div>\\\n\\\n<div class="pull-right">\\\n<%= link_to "<span class=\\\\"glyphicon glyphicon-plus-sign\\\\" aria-hidden=\\\\"true\\\\"><\\/span> New \\1".html_safe, [:new, :#{Bootscaf::Utils.singularize(modelname)}], class: "btn btn-success" %>\\\n<\\/div>\\\nListing \\1s\\\n<\\/h1>\\\n<\\/div>\\\n\\\n<table class="table table-striped table-hover tablesorter" id="#{modelname}-table">/' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<th>\\(.*\\)<\\/th>/<th><span>\\1<\\/span><\\/th>/g' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<table>//' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<\\/table>/<\\/table>\\\n<\\/div>/' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<th colspan="3"><\\/th>//' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<td><%= link_to '\\''Show'\\'', \\(.*\\) %><\\/td>//' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<td><%= link_to '\\''Edit'\\'', edit_\\(.*\\)_path(\\(.*\\)) %><\\/td>//' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<td><%= link_to '\\''Destroy'\\'', \\(.*\\), method: :delete, data: { confirm: '\\''Are you sure?'\\'' } %><\\/td>//' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<% @#{modelname}.each do \\|#{singular_modelname}| %>/<% unless @#{modelname}.any? %>\\\n<tr id="empty-table">\\\n<td class="bg-warning" colspan="2">No #{modelname} created yet.<\\/td>\\\n<\\/tr>\\\n<% end %>\\\n<% @#{modelname}.each do \\|#{singular_modelname}| %>\\\n<tr class="linked-row" data-href="<%= #{singular_modelname}_path(#{singular_modelname}) %>">/' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<tr>//' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<thead>/<thead>\\\n<tr>/' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<td><%= #{singular_modelname}.\\(.*\\) %><\\/td>/<td><%= link_to #{singular_modelname}.\\1, #{singular_modelname} %><\\/td>/' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<br>//' app/views/#{modelname}/index.html.erb`
        print `sed #{icmd} -e 's/<%= link_to '\\''New \\(.*\\)'\\'', new_\\(.*\\)_path %>//' app/views/#{modelname}/index.html.erb`
        print "\n"
        
        print "Updating app/views/#{modelname}/new.html.erb. "
        print `sed #{icmd} -e 's/<h1>New \\(.*\\)<\\/h1>/<% content_for :page_title do %>\\\nCreate \\1 - \\\n<% end %>\\\n<div class="container">\\\n<div class="page-header">\\\n<h1>\\\nNew \\1\\\n<\\/h1>\\\n<\\/div>/' app/views/#{modelname}/new.html.erb`
        print `sed #{icmd} -e 's/<%= link_to '\\''Back'\\'', \\(.*\\)s_path %>/<div class="clearfix"><\\/div>\\\n<%= link_to "<span class=\\\\"glyphicon glyphicon-ban-circle\\\\" aria-hidden=\\\\"true\\\\"><\\/span> Cancel".html_safe, \\1s_path, class: "btn btn-default" %>\\\n<\\/div>/' app/views/#{modelname}/new.html.erb`
        print "\n"
        
        print "Updating app/views/#{modelname}/show.html.erb. "
        print `sed #{icmd} -e 's/<p id="notice"><%= notice %><\\/p>/<% content_for :page_title do %>\\\n#{Bootscaf::Utils.singularize(modelname).capitalize} Details - \\\n<% end %>\\\n<div class="container">\\\n<div class="page-header">\\\n<h1>\\\n<div class="pull-left">\\\n<%= link_to "<span class=\\\\"glyphicon glyphicon-step-backward\\\\" aria-hidden=\\\\"true\\\\"><\\/span>".html_safe, #{modelname}_path, class: "btn btn-default", title: "Back to #{modelname}" %>\\\n\\&nbsp;\\\n<\\/div>\\\n<div class="pull-right">\\\n<%= link_to "<span class=\\\\"glyphicon glyphicon-pencil\\\\" aria-hidden=\\\\"true\\\\"><\\/span> Edit".html_safe, edit_#{Bootscaf::Utils.singularize(modelname)}_path(@#{Bootscaf::Utils.singularize(modelname)}), class: "btn btn-warning" %>\\\n<\\/div>\\\n#{Bootscaf::Utils.singularize(modelname).capitalize} Details\\\n<\\/h1>\\\n<\\/div>/' app/views/#{modelname}/show.html.erb`
        print `sed #{icmd} -e 's/<p>/<div class="row">/' app/views/#{modelname}/show.html.erb`
        print `sed #{icmd} -e 's/<\\/p>/<\\/div>/' app/views/#{modelname}/show.html.erb`
        print `sed #{icmd} -e 's/<strong>\\(.*\\):<\\/strong>/<label class="col-sm-3 text-right text-muted">\\1<\\/label>/g' app/views/#{modelname}/show.html.erb`
        print `sed #{icmd} -e 's/<%= @\\(.*\\)\\.\\(.*\\) %>/<div class="col-sm-9"><%= @\\1.\\2 %><\\/div>/g' app/views/#{modelname}/show.html.erb`
        print `sed #{icmd} -e 's/<%= link_to '\\''Edit'\\'', edit_\\(.*\\)_path(@\\(.*\\)) %> \\|/<\\/div>/' app/views/#{modelname}/show.html.erb`
        print `sed #{icmd} -e 's/<%= link_to '\\''Back'\\'', \\(.*\\)s_path %>//' app/views/#{modelname}/show.html.erb`
        print "\n"
      end
    end
    
  end
end
