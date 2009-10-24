require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe WardenStrategies::Simple do
  before do
    @env = Rack::MockRequest.env_for("/", :input => Rack::Utils.build_query(
      :name => "Homer", "foo[bar]" => "baz"
    ))
    class ::User; end
  end

  it "should setup the spec correctly" do
    req = Rack::Request.new(@env)
    req.params["name"].should == "Homer"
    req.params["foo"]["bar"].should == "baz"
  end

  it "should provide me with a configuration hash" do
    WardenStrategies::Simple.config.should be_a_kind_of(Hash)
  end

  it "should allow me to specify the configuration via a block" do
    WardenStrategies::Simple.config do |c|
      c[:stuff] = :stuff
    end
    WardenStrategies::Simple.config[:stuff].should == :stuff
  end

  describe "required params" do
    before do
      class SimpleFoo < WardenStrategies::Simple
        config[:required_params] = [:login, :password]
      end
    end

    it "should set simple symbol or string required params" do
      SimpleFoo.config[:required_params] = [:login, "password"]
      SimpleFoo.required_params.should == [:login, "password"]
    end

    it "should provide me with access to the required params at an instance level" do
      SimpleFoo.config[:required_params] = [:login, "password"]
      SimpleFoo.new(@env).required_params.should == [:login, "password"]
    end

    it "should provide the required param values from the required params" do
      env = env_with_params("/", :login => "foo", :password => "bar")
      SimpleFoo.config[:required_params] = [:login, "password"]
      s = SimpleFoo.new(env).required_param_values.should == ["foo", "bar"]
    end

    it "should set nested_params with a single value" do
      env = env_with_params("/", :login => "foo", "foo[bar]" => "baz")
      SimpleFoo.config[:required_params] = [:login, "foo:bar"]
      s = SimpleFoo.new(env).required_param_values.should == ["foo", "baz"]
    end

    it "should set deeply nested params" do
      env = env_with_params("/", :login => "foo", "foo[bar][baz]" => "paz")
      SimpleFoo.config[:required_params] = [:login, "foo:bar:baz"]
      s = SimpleFoo.new(env).required_param_values.should == ["foo", "paz"]
    end

    it "should set rediculously deeply nested params" do
      env = env_with_params("/", :login => "foo", "foo[bar][baz][paz][soz][kaz]" => "homer")
      SimpleFoo.config[:required_params] = [:login, "foo:bar:baz:paz:soz:kaz"]
      s = SimpleFoo.new(env).required_param_values.should == ["foo", "homer"]
    end

    it "should set a nested param as a proc" do
      env = env_with_params("/", :login => "foo", "sammy" => "barry")
      SimpleFoo.config[:required_params] = [:login, Proc.new{ params["sammy"] }]
      s = SimpleFoo.new(env).required_param_values.should == ["foo", "barry"]
    end

    it "should be valid if all required params are found" do
      env = env_with_params("/", :login => "foo", "sammy" => "barry")
      SimpleFoo.config[:required_params] = [:login, :sammy]
      s = SimpleFoo.new(env).should be_valid
    end

    it "should be invalid if all required params are not found" do
      env = env_with_params("/", :login => "foo")
      SimpleFoo.config[:required_params] = [:login, :bar]
      s = SimpleFoo.new(env).should_not be_valid
    end

    it "should be valid with no required_params set" do
      env = env_with_params("/")
      SimpleFoo.config[:required_params] = nil
      s = SimpleFoo.new(env).should be_valid
    end

    it "should be valid with an emtpy array for a required_params" do
      env = env_with_params("/")
      SimpleFoo.config[:required_params] = []
      s = SimpleFoo.new(env).should be_valid
    end

    it "should be invalid with a nested param missing" do
      env = env_with_params("/")
      SimpleFoo.config[:required_params] = [:login, "foo:bar:baz"]
      s = SimpleFoo.new(env).should_not be_valid
    end
  end

  describe "validating a strategy" do
    before do
      class SimpleFoo < WardenStrategies::Simple; end
      class ::User
        def self.authenticate(login)
          login == "fred"
        end
      end

      app = lambda do |env|
        env['warden'].authenticate!
        Rack::Response.new("OK").finish
      end

      fail_app = lambda do |env|
        Rack::Response.new("FAIL").finish
      end

      Warden::Strategies.add(:simple, SimpleFoo)

      @app = Rack::Builder.new do
        use Rack::Session::Cookie
        use Warden::Manager do |manager|
          manager.default_strategies :simple
          manager.failure_app = fail_app
        end
        run app
      end
    end

    after do
      Warden::Strategies.clear!
    end

    it "should validate a class by supplying the required params to the authenticate method" do
      env = env_with_params("/", :login => "fred")
      SimpleFoo.config[:required_params] = [:login]
      s = SimpleFoo.new(env)
      User.should_receive(:authenticate).with("fred").and_return("fred")
      s.authenticate!
      s.result.should == :success
    end

    it "should fail the validation if the param is nil or false" do
      env = env_with_params("/")
      SimpleFoo.config[:required_params] = [:login]
      s = SimpleFoo.new(env)
      s.should_not be_valid
      User.should_not_receive(:authenticate)
      @app.call(env)
    end

    it "should validate with a different return method" do
      env = env_with_params("/", :login => "fred")
      SimpleFoo.config[:required_params] = [:login]
      SimpleFoo.config[:authenticate_method] = :authenticate_for_fred
      User.should_receive(:authenticate_for_fred).and_return("fred")
      s = SimpleFoo.new(env)
      s.should be_valid
      result = @app.call(env)
      result[2].body.should include("OK")
    end
  end
end
