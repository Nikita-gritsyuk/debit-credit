source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.1.1"
gem "rails", "~> 7.0.3", ">= 7.0.3.1"
gem 'devise'
gem "sprockets-rails"
gem 'pg'
gem "puma", "~> 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem 'will_paginate', '~> 3.3'
gem 'will_paginate-bootstrap-style'
gem "redis", "~> 4.0"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]
gem "haml-rails", "~> 2.0"
gem "bootsnap", require: false
gem "bootstrap"
gem "sassc-rails"
gem 'draper'

group :development, :test do  
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "pry"
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem 'dotenv-rails'
end

group :development do
  gem "web-console"
  gem "rubocop"
  gem 'rubocop-rails', require: false
  gem "erb2haml", :group => :development
end

group :test do  
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  gem 'shoulda-matchers', '~> 4.0'
end