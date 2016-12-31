require 'middleman-core'
require 'middleman-keycdn/commands/invalidate'

module Middleman
  module KeyCDN
    class Extension < Middleman::Extension
      # @param [Symbol] key The name of the option
      # @param [Object] default The default value for the option
      # @param [String] description A human-readable description of what the option does
      option :api_key, nil, 'API key'
      option :zone_id, nil, 'Zone id'
      option :base_url, nil, 'The base url for the site (only required when purging individual urls'
      option :purge_all, true, 'Purge the whole cache (true) or individual urls (false)'
      option :filter, /.*/, 'Filter files to be invalidated'
      option :after_build, false, 'Invalidate after build'

      def initialize(app, options_hash={}, &block)
        super
      end

      def after_build
        Middleman::Cli::KeyCDN::Invalidate.new.invalidate(options) if options.after_build
      end

      helpers do
        def invalidate(files = nil)
          Middleman::Cli::KeyCDN::Invalidate.new.invalidate(options, files)
        end
      end
    end
  end
end
