require 'pathname' # for some reason, had to require this because middleman-core 4.1.7 did not.
require 'middleman-keycdn/extension'

Middleman::Extensions.register :keycdn, Middleman::KeyCDN::Extension
