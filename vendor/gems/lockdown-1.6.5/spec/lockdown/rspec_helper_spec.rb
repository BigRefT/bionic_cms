require File.join(File.dirname(__FILE__), %w[.. spec_helper])

require 'lockdown/rspec_helper'

class TestAController
  extend Lockdown::Frameworks::Rails::Controller
  include Lockdown::Frameworks::Rails::Controller::Lock
end

class RspecEnv
end

describe Lockdown::RspecHelper do
  before do
    @controller = TestAController.new
    @controller.stub!(:session).and_return({})

    usr = mock  :user, 
                :first_name => 'John',
                :last_name  => 'Smith',
                :password   => 'mysecret',
                :password_confirmation  => 'mysecret'

    usr_group = mock :usr_group

    Lockdown.should_receive(:maybe_parse_init)
    RspecEnv.send :include, Lockdown::RspecHelper
    @rspec_env = RspecEnv.new
    @rspec_env.stub!(:controller).and_return(@controller)
    @rspec_env.stub!(:mock_user).and_return(usr)
    @rspec_env.stub!(:mock_user_group).and_return(usr_group)
  end

  describe "#login_admin" do
    it "should set access_rights to :all" do 
      @rspec_env.login_admin
      @rspec_env.controller.session[:access_rights].should == :all
    end
  end
end
