module WardenStrategies

  # The Simple strategy is a strategy that will accept a simple list of requried parameters, a user class
  # an authenticate_method and an error message and use those to authenticate a "user"
  #
  # The following example will create a strategy that will check an account for a user login
  # with the Account class using the authenitcate_account_holder method.
  #
  # for the given params "login" => "fred", "password => "sekrit", "account" => "main"
  # The following would be called if all parameters are present
  # Account.authenticate_account_holder("fred", "sekrit", "main")
  #
  # @example
  #   class AccountStrategy < WardenStrategies::Base
  #     config.merge!(
  #       :user_class           => Account,
  #       :authenticate_method  => :authenticate_account_holder,
  #       :required_params      => [:login, :password, :account]
  #     )
  #   end
  #
  #   Warden::Strategies.add(:account, AccountStrategy)
  #
  #   # calls Account.authenticate_account_holder("login_param", "password_param", "account_param")
  #
  # @see WardenStrategies::Simple.config
  class Simple < WardenStrategies::Base

    # Sets the configuration for this strategy.
    #
    # The config will return and yeild a hash (if a block is given) with the configuration for this strategy.
    # The following options are available
    #
    # :user_class
    # :required_params
    # :authenticate_method
    # :error_message
    #
    # :user_class option will set the class for this strategy.  If no user class is defined the super classes user_class method is called instead. Default - User
    #
    # :required_params is an array of required params that must be present for this strategy to run.  Once the strategy is run, then these parameters are passed to the :authenticate_method in the order specified.
    # The params can be specified as a symbol, a string, or a nested param.  To specify a nested param seperate the string with a :
    # Default []
    #
    # :authenticate_method specifies the method to call on the user_class when all the parameters are present
    # Default :authenticate
    #
    # :error_message specifies the error message to call when the strategy fails (providing it's valid)
    # Default "Could not login"
    #
    # @example
    # class MyStrategy < WardenStrategies::Simple
    # config do |c|
    #   c[:required_params]     = [:login, :password]
    #   c[:authenticate_method] = :authenticate_with_password
    # end
    #
    # @api public
    def self.config
      @config ||= {
        :authenticate_method  => :authenticate,
        :error_message        =>  "Could not login"
      }
      yield @config if block_given?
      @config
    end

    # Returns the configured required_params for this class
    # @api public
    # @see  WardenStrategies::Simple.config
    def self.required_params
      config[:required_params] ||= []
    end

    # Provides access to the required param for this class
    # @see WardenStrategies::Simple.required_params
    # @api public
    def required_params
      self.class.required_params
    end

    # Provides access to the User class for this strategy
    # @see WardenStrategies::Simple.config
    # @api public
    def user_class
      config[:user_class] || super
    end

    # Sets used in strategy selection.  Returns true if all required_params are available in the request
    # @return true if all valid params are returned false otherwise
    # @see Warden::Strategy::Base#valid?
    # @api private
    def valid?
      required_param_values.nil? ? false : !required_param_values.include?(nil)
    end

    # The workhorse.  Will pass all requred_param_values to the configured authenticate_method
    # @see WardenStrategies::Simple.config
    # @see Warden::Strategy::Base#authenticate!
    # @api private
    def authenticate!
      if u = user_class.send(config[:authenticate_method], *required_param_values)
        success!(u)
      else
        fail!(config[:error_message])
      end
    end

    # @return the values of the required params for the required_params, or nil if one of the params is not found
    # @api public
    def required_param_values
      result = required_params.map do |val|
        r = extract_value_from_params(val)
        break if r.nil?
        r
      end
      result
    end

    # Provides access to the config hash for this strategy
    def config
      self.class.config
    end

    private
    def extract_value_from_params(key)
      case key
      when String, Symbol
        keys = key.to_s.split(":")
        if keys.size == 1
          params[keys.first]
        else
          keys.inject(params){|p,k| p[k]}
        end
      when Proc
        instance_eval(&key)
      end
    end

  end
end
