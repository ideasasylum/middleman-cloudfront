require 'middleman-cli'
require 'middleman-keycdn/extension'
require 'keycdn'
require 'ansi/code'

module Middleman
  module Cli
    module KeyCDN
      # This class provides an "invalidate" command for the middleman CLI.
      class Invalidate < ::Thor::Group
        include Thor::Actions

        INVALIDATION_LIMIT = 1000
        INDEX_REGEX = /
          \A
            (.*\/)?
            index\.html
          \z
        /ix

        check_unknown_options!

        def self.exit_on_failure?
          true
        end

        def invalidate(opts = nil, files = nil)
          @options = setup_options opts

          ensure_required_options_present

          if @options.purge_all
            purge_all
          else
            purge_urls files
          end
        end

        protected

        def setup_options opts
          # If called via commandline, discover config (from bin/middleman)
          if opts.nil?
            app = Middleman::Application.new do
              config[:mode] = :config
              config[:exit_before_ready] = true
              config[:watcher_disable] = true
              config[:disable_sitemap] = true
            end

            # Get the opts from the keycdn extension
            extension = app.extensions[:keycdn]
            unless extension.nil?
              opts = extension.options
            end
          end

          if opts.nil?
            configuration_usage
          end

          opts
        end

        def ensure_required_options_present
          [:api_key, :zone_id, :base_url].each do |key|
            raise StandardError, "Configuration key #{key} is missing." if @options.public_send(key).nil?
          end

          if !@options.purge_all
            [:base_url, :filter].each do |key|
              raise StandardError, "Configuration key #{key} is missing." if @options.public_send(key).nil?
            end
          end
        end

        def purge_all
          puts "Invalidating KeyCDN cache for #{@options.zone_id}"
          response = cdn.get("zones/purge/#{@options.zone_id}.json")
          print_status response
        end

        def purge_urls files
          files = normalize_files(files || list_files(@options.filter))
          return if files.empty?
          urls = files.collect.with_index { |file, index| ["urls[#{index}]", "#{@options.base_url}#{file}"] }
          puts "Invalidating #{files.count} urls."
          # puts urls.inspect
          response = cdn.del("zones/purgeurl/#{@options.zone_id}.json", Hash[urls])
          print_status response
        end

        def print_status response
          if response['status'] == 'success'
            puts ANSI.green { "#{response['description']}" }
          else
            puts ANSI.red { "#{response['description']}" }
          end
        end

        def cdn
          ::KeyCDN::Client.new @options.api_key
        end

        def configuration_usage
          raise StandardError, <<-TEXT
ERROR: You need to activate the keycdn extension in config.rb.

The example configuration is:
activate :keycdn do |cf|
  cf.api_key = ENV['KEYCDN_API_KEY']
  cf.zone_id = ENV['KEYCDN_ZONE_ID']
  cf.base_url = ENV['KEYCDN_BASE_URL']
  cf.purge_all = false
  cf.filter = /.html$/i  # default is /.*/
  cf.after_build = true  # default is false
end
          TEXT
        end

        def list_files(filter)
          Dir.chdir('build/') do
            Dir.glob('**/*', File::FNM_DOTMATCH).tap do |files|
              # Remove directories
              files.reject! { |f| File.directory?(f) }

              # Remove files that do not match filter
              files.reject! { |f| f !~ filter }
            end
          end
        end

        def normalize_files(files)
          # Add directories since they have to be invalidated
          # as well if :directory_indexes is active
          files += files.grep(INDEX_REGEX).map do |file|
            file == 'index.html' ? '/' : File.dirname(file) << '/'
          end.uniq

          # URI encode and add leading slash
          files.map { |f| URI::encode(f.start_with?('/') ? f : "/#{f}") }
        end

        # Add to CLI
        Base.register(self, 'invalidate', 'invalidate', 'Invalidate a KeyCDN zone.')

        # Map "inv" to "invalidate"
        Base.map('inv' => 'invalidate')
      end
    end
  end
end
