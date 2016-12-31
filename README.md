# Middleman KeyCDN [![Build Status](https://travis-ci.org/ideasasylum/middleman-keycdn.svg?branch=master)](https://travis-ci.org/ideasasylum/middleman-keycdn) [![Dependency Status](https://gemnasium.com/ideasasylum/middleman-keycdn.png)](https://gemnasium.com/ideasasylum/middleman-keycdn) [![Code Climate](https://codeclimate.com/github/ideasasylum/middleman-keycdn.png)](https://codeclimate.com/github/ideasasylum/middleman-keycdn)

A deploying tool for middleman which invalidates a [KeyCDN](https://www.keycdn.com/?a=25888) cache.

Based almost entirely on [middleman-cloudfront](https://github.com/andrusha/middleman-cloudfront) and used together with [middleman-s3_sync](https://github.com/fredjean/middleman-s3_sync) (though you can use whatever deployment method & KeyCDN source you want)

Some of its features are:  

* KeyCDN cache invalidation &mdash; either purge the whole cache or just updated selected URLs;
* Ability to call it from command line and after middleman build;  
* Ability to filter files which are going to be invalidated by regex;  

# Usage

## Installation

Add this to `Gemfile`:  
```ruby
gem 'middleman-keycdn'
```

Then run:
```
bundle install
```

## Configuration

Edit `config.rb` and add:  

```ruby
activate :keycdn do |cdn|
  cdn.api_key = ENV['KEYCDN_API_KEY']
  cdn.zone_id = ENV['KEYCDN_ZONE_ID']
  cdn.base_url = ENV['KEYCDN_BASE_URL']
  cdn.purge_all = true
  cdn.filter = /.html$/i  # default is /.*/
  cdn.after_build = true  # default is false
end```

## Running

If you set `after_build` to `true` cache would be automatically invalidated after build:  
```bash
bundle exec middleman build
```

Otherwise you should run it through commandline interface like so:  
```bash
bundle exec middleman invalidate
```
