# -*- encoding: utf-8 -*-
Notiz::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  APP = { :domain => "notiz.local",
          :name   => "測試-notiz - ",
          :url    => "http://notiz.local.airfont.com",
          :portal => "notiz.local.airfont.com",
          :assets => "http://www.airfont.com",
          :port => "", #":30034"
          :supervisor => 'chitsung.lin@gmail.com'
  }


  config.cache_store = :dalli_store, '127.0.0.1:11211', { :namespace => 'notiz', :expires_in => 1.day, :compress => true }

  $APPNAME = "(測)Notiz"
  $SNIPPET_HOST = "notiz.local"
  config.action_mailer.default_url_options = {:host => 'notiz.local.airfont.com' }
  ActionController::Base.asset_host = $SNIPPET_HOST

  # config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  config.log_level = :debug

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log


  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false

  config.sass.line_comments = true
  config.sass.syntax = :nested
  config.sass.preferred_syntax = :sass
end
