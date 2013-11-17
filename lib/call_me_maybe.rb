# Load our specificly requested AS components
require "active_support/core_ext/module/attribute_accessors"
require "active_support/inflector"
require 'awesome_print'

# Load in the Call Me Maybe files
require "call_me_maybe/version"
require "call_me_maybe/exchange"
require "call_me_maybe/module"

# Add in the `call_me_maybe` command
module CallMeMaybe
  class << self
    def setup
      ::Module.__send__(:include, CallMeMaybe::Module)
    end
  end
end

# Startup the module
CallMeMaybe.setup
