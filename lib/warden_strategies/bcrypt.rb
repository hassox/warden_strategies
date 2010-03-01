module WardenStrategies

  # Create a migration for the following fields:
  # _crypted_password  -  String
  # _password_salt     -  String
  #
  # Then include WardenStrategies::Bcrypt::Mixins::ActiveRecord
  #
  # @example
  # class MyClass < ActiveRecord::Base
  #   include WardenStrategies::Bcrypt::Mixins::ActiveRecord
  # end
  class Bcrypt < WardenStrategies::Simple
    module Mixins
      autoload :Base,         "warden_strategies/bcrypt/base"
      autoload :ActiveRecord, "warden_strategies/bcrypt/active_record"
    end

    config do |c|
      c[:required_params]     = [:login, :password]
      c[:authenticate_method] = :authenticate_with_bcrypt
      c[:error_message]       = "Username or Password incorrect"
    end
  end
end

Warden::Strategies.add(:simple_bcrypt, WardenStrategies::Bcrypt)
