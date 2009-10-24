require File.expand_path(File.join(File.dirname(__FILE__), '..', 'spec_helper'))

describe WardenStrategies::Base do
  before do
    @env = Rack::MockRequest.env_for("/")
    class ::User; end
  end

  it "should allow me to get the User class by default" do
    s = WardenStrategies::Base.new(@env, scope = :default)
    s.user_class.should == User
  end

  it "should allow me to get this in a subclass" do
    class ::AStrategy < WardenStrategies::Base
    end

    s = AStrategy.new(@env)
    s.user_class.should == User
  end



end
