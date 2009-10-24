require 'warden'
$:.push(File.expand_path(File.dirname(__FILE__)))

module WardenStrategies
  autoload :Base,     "warden_strategies/base"
  autoload :Simple,   "warden_strategies/simple"
end
