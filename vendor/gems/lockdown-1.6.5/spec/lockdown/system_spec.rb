require File.join(File.dirname(__FILE__), %w[.. spec_helper])
require File.join(File.dirname(__FILE__), %w[.. .. lib lockdown rules])

describe Lockdown::System do
  it "should fetch the option" do
    Lockdown::System.options = {}
    Lockdown::System.options['test'] = "my test"
    Lockdown::System.fetch('test').should == "my test"
  end
  
  describe "#configure" do
    it "should call the methods responsible for defining the rules" do
      Lockdown::System.stub!(:skip_sync?).and_return(false)

      Lockdown::System.should_receive :set_defaults 
 
      Lockdown::System.should_receive :instance_eval
 
      Lockdown::System.should_receive :process_rules
 
      Lockdown::Database.should_receive :sync_with_db 
     
      Lockdown.should_receive :caching?

      Lockdown::System.configure do
      end
    end
  end

  describe "#paths_for" do
    it "should join the str_sym to the methods" do 
      Lockdown::System.paths_for(:users, :show, :edit).
        should == ["users/show", "users/edit"]
    end

    it "should add users to the array if access is granted on index" do 
      Lockdown::System.paths_for(:users, :index, :show, :edit).
        should == ["users/index", "users/show", "users/edit", "users"]
    end

    it "should build the paths from the controller class if no methods specified" do
      methods = ["new","edit","create","update"]
      Lockdown.stub!(:fetch_controller_class)
      Lockdown::System.stub!(:available_actions).
        and_return(methods)

      Lockdown::System.paths_for(:users).
        should == ["users/new","users/edit","users/create","users/update"]
    end
  end
end
