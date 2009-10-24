module WardenStrategies
  class Base < Warden::Strategies::Base

    # Provides access to a user class.
    # this should be overwritten in sub-classes to provde access
    # to particular user classes
    #
    # @return A class to use as the "User" class for the request to use
    # @api overwritable
    def user_class
      User
    end
  end
end
