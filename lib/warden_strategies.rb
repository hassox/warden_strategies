require 'warden'
$:.push(File.expand_path(File.dirname(__FILE__)))

module WardenStrategies
  autoload :Base,     "warden_strategies/base"
  autoload :Simple,   "warden_strategies/simple"
  autoload :Bcrypt,    "warden_strategies/bcrypt"

  module Mixins
    module Bcrypt
       autoload :Base,          "warden_strategies/bcrypt/base"
       autoload :ActiveRecord,  "warden_strategies/bcrypt/active_record"
    end
  end
end
