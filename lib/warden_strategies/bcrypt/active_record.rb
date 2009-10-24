module WardenStrategies
  class Bcrypt

    module Mixins
      module ActiveRecord
        def self.included(base)
          base.class_eval do
            extend  WardenStrategies::Bcrypt::Mixins::ActiveRecord::ClassMethods
            include WardenStrategies::Bcrypt::Mixins::Base

            attr_accessor :password, :password_confirmation

            validates_presence_of     :crypted_password, :on => :update,  :if => :has_no_credentials?
            validates_confirmation_of :password, :if => :password
          end
        end

        module ClassMethods
          def authenticate_with_bcrypt(login, password)
            user = self.find_by_login(login)
            return nil unless user
            user.crypted_password == "#{password}#{user.password_salt}"
          end
        end
      end
    end
  end
end
