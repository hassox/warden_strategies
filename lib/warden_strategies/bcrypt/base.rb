module WardenStrategies
  class Bcrypt
    module Mixins
      module Base
        def password=(pass)
          @password = pass
          unless pass.blank?
            self._crypted_password =  pass.nil? ? nil : ::BCrypt::Password.create("#{pass}#{password_salt}", :cost => 10)
          end
          @password
        end

        def crypted_password
          @crypted_password ||= begin
            ep = _crypted_password
            ep.nil? ? nil : ::BCrypt::Password.new(ep)
          end
        end

        def password_salt
          @password_salt ||= begin
            pws = _password_salt
            pws.nil? ? (self._password_salt = Digest::SHA512.hexdigest(unique_token)) : pws
          end
        end

        def has_no_credentials?
          self._crypted_password.blank?
        end

        def unique_token
          Time.now.to_s + (1..10).collect{ rand.to_s }.join
        end
      end
    end
  end
end
