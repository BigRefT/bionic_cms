require File.join(File.dirname(__FILE__), %w[.. .. spec_helper])

describe Lockdown::Frameworks::Rails do
  before do
    @rails = Lockdown::Frameworks::Rails

    @rails.stub!(:use_me?).and_return(true)

    @lockdown = mock("lockdown")        
  end


  describe "#included" do
    it "should extend lockdown with rails environment" do
      @lockdown.should_receive(:extend).
        with(Lockdown::Frameworks::Rails::Environment)

      @rails.should_receive(:mixin)

      @rails.included(@lockdown)
    end
  end

  describe "#mixin" do
    it "should perform class_eval on controller view and system to inject itself" do

      @view_helper = Mikey
      @view_helper.should_receive(:include).
        with( Lockdown::Frameworks::Rails::View )

      Lockdown.should_receive(:view_helper) do 
        @view_helper
      end

      @system = Mikey
      @system.should_receive(:extend).
        with( Lockdown::Frameworks::Rails::System )

      Lockdown.should_receive(:system) do 
        @system
      end

      @rails.should_receive(:mixin_controller)

      @rails.mixin
    end

  end

  describe "#mixin_controller" do

    it "should inject itself" do
      klass = Mikey

      klass.should_receive(:include).
        with(Lockdown::Session)

      klass.should_receive(:include).
        with(Lockdown::Frameworks::Rails::Controller::Lock)

      klass.should_receive(:helper_method).with(:authorized?)

      klass.should_receive(:hide_action).with(:set_current_user, :configure_lockdown, :check_request_authorization, :check_model_authorization)

      klass.should_receive(:before_filter).and_return do |c|
        #not working yet. very frustrating trying to test this
      end

      klass.should_receive(:filter_parameter_logging)

      klass.should_receive(:rescue_from)

      @rails.mixin_controller(klass)
    end
  end

end

RAILS_ROOT = "/shibby/dibby/do"

module ActionController; class Base; end end

class ApplicationController; end

module ActionView; class Base; end end

describe Lockdown::Frameworks::Rails::Environment do

  before do
    @env = class Test; extend Lockdown::Frameworks::Rails::Environment; end
  end

  describe "#project_root" do
    it "should return rails root" do
      @env.project_root.should == "/shibby/dibby/do"
    end
  end

  describe "#init_file" do
    it "should return path to init_file" do
      @env.stub!(:project_root).and_return("/shibby/dibby/do")
      @env.init_file.should == "/shibby/dibby/do/lib/lockdown/init.rb"
    end
  end

  describe "#controller_class_name" do
    it "should add Controller to name" do
      @env.controller_class_name("user").should == "UserController"
    end

    it "should convert two underscores to a namespaced controller" do
      @env.controller_class_name("admin__user").should == "Admin::UserController"
    end
  end

  describe "#controller_parent" do
    it "should return ActionController::Base if not caching classes" do
      @env.should_receive(:caching?).and_return(false)
      @env.controller_parent.should == ActionController::Base
    end

    it "should return ApplicationController if caching classes" do
      @env.should_receive(:caching?).and_return(true)
      @env.controller_parent.should == ApplicationController
    end

  end

  describe "#view_helper" do
    it "should return ActionView::Base" do
      
      @env.view_helper.should == ActionView::Base
    end
  end
end

describe Lockdown::Frameworks::Rails::System do
  class Test 
    extend Lockdown::Frameworks::Rails::System
  end

  before do
    @env = Test
  end

  describe "#skip_sync?" do
    it "should return true if env == skip sync" do
      Lockdown::System.stub!(:fetch).with(:skip_db_sync_in).and_return(['test'])
      @env.should_receive(:framework_environment).and_return("test")
      
      @env.skip_sync?.should == true
    end

    it "should return false if env not in skip_sync" do
      Lockdown::System.stub!(:fetch).with(:skip_db_sync_in).and_return(['test', 'ci'])
      @env.should_receive(:framework_environment).and_return("qa")
      
      @env.skip_sync?.should == false
    end
    
  end

end
