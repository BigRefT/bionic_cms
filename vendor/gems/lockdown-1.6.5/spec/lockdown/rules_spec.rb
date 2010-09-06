require File.join(File.dirname(__FILE__), %w[.. spec_helper])

class TestSystem; extend Lockdown::Rules; end

describe Lockdown::Rules do
  before do
    @rules = TestSystem
    @rules.set_defaults
  end

  describe "#set_permission" do
    it "should create and return a Permission object" do
      @rules.set_permission(:user_management).
        should == Lockdown::Permission.new(:user_management) 
    end
  end

  describe "#set_public_access" do
    it "should define the permission as public" do
      @rules.set_permission(:home_page)
      @rules.set_public_access(:home_page)
      perm = @rules.permission_objects.find{|name, object| name == :home_page}
      perm[1].public_access?.should be_true
    end

    it "should raise and InvalidRuleAssignment if permission does not exist" do
      msg = "Permission not found: toy_management"

      @rules.should_receive(:raise).with(Lockdown::InvalidRuleAssignment, msg)

      @rules.set_public_access(:toy_management)
    end
  end

  describe "#public_access?" do
    it "should return true when permission is public" do
      @rules.set_permission(:home_page)
      @rules.set_public_access(:home_page)
      @rules.public_access?(:home_page).should == true
    end

    it "should return false when permission is not public" do
      @rules.set_permission(:home_page)
      @rules.set_protected_access(:home_page)
      @rules.public_access?(:home_page).should == false
    end
  end

  describe "#set_protected_access" do
    it "should define the permission as protected" do
      @rules.set_permission(:user_management)
      @rules.set_protected_access(:user_management)
      perm = @rules.permission_objects.find{|name, object| name == :user_management}
      perm[1].protected_access?.should be_true
    end

    it "should raise and InvalidRuleAssignment if permission does not exist" do
      msg = "Permission not found: user_management"

      @rules.should_receive(:raise).with(Lockdown::InvalidRuleAssignment, msg)

      @rules.set_protected_access(:user_management)
    end
  end

  describe "#protected_access?" do
    it "should return true when permission is protected" do
      @rules.set_permission(:home_page)
      @rules.set_protected_access(:home_page)
      @rules.protected_access?(:home_page).should == true
    end

    it "should return false when permission is not protected" do
      @rules.set_permission(:home_page)
      @rules.set_public_access(:home_page)
      @rules.protected_access?(:home_page).should == false
    end
  end

  describe "#get_permissions" do
    it "should return array of permission names as symbols" do
      Lockdown.should_receive(:add_controller_method)
      
      @rules.set_permission(:home_page)
      @rules.set_permission(:user_management)
      @rules.process_rules
      @rules.get_permissions.should include(:home_page) 
      @rules.get_permissions.should include(:user_management)
    end
  end

  describe "#permission_exists?" do
    it "should return true if permission exists" do
      Lockdown.should_receive(:add_controller_method)

      @rules.set_permission(:home_page)
      @rules.process_rules
      @rules.permission_exists?(:home_page).should be_true
    end

    it "should return false if permission does not exist" do
      @rules.permission_exists?(:home_page).should be_false
    end
  end

  describe "#permission_assigned_automatically?" do
    it "should return true when permission is public" do
      @rules.set_permission(:home_page)
      @rules.set_public_access(:home_page)
      @rules.permission_assigned_automatically?(:home_page).should == true
    end

    it "should return true when permission is protected" do
      @rules.set_permission(:home_page)
      @rules.set_protected_access(:home_page)
      @rules.permission_assigned_automatically?(:home_page).should == true
    end

    it "should return false when permission is not public" do
      @rules.set_permission(:home_page)
      @rules.permission_assigned_automatically?(:home_page).should == false
    end
  end

  describe "#get_user_groups" do
    it "should return array of user group names as symbols" do
      @rules.set_permission(:user_management)
      @rules.set_user_group(:security_management, :user_management)
      @rules.get_user_groups.should == [:security_management]
    end
  end

  describe "#user_group_exists?" do
    it "should return true if user_group exists" do
      @rules.set_user_group(:user_management, :some_perm)
      @rules.user_group_exists?(:user_management).should be_true
    end

    it "should return false if user_group does not exist" do
      @rules.user_group_exists?(:user_management).should be_false
    end
  end

  describe "#make_user_administrator" do
    it "should add admin to user groups" do
      ugc = mock('user_group_class',:find_or_create_by_name => :admin)
      Lockdown.should_receive(:user_group_class).and_return(ugc)

      usr = mock('user', :user_groups => [])

      @rules.make_user_administrator(usr).should include(:admin)
    end
  end

  describe "#access_rights_for_user" do
    it "should array of rights for user who is not an admin" do
      @rules.should_receive(:administrator?).and_return(false)

      @rules.set_permission(:register_account).
        with_controller(:users).
        only_methods(:new, :create)

      @rules.set_public_access(:register_account)

      perm = @rules.set_permission(:perm_one).
        with_controller("a_controller").
        only_methods("show","edit","update")

      ug = @rules.set_user_group(:ug_one, :perm_one)

      @rules.should_receive(:set_model_access)
      @rules.process_rules

      usr = mock('user', :user_groups => [:ug_one])

      @rules.access_rights_for_user(usr).
        should == ["users/new", "users/create", "a_controller/show", "a_controller/edit", "a_controller/update"]
    end
  end

  describe "#access_rights_for_user_group" do
    it "should return array of rights for user_group" do
      perm = @rules.set_permission(:perm_one).
        with_controller("a_controller").
        only_methods("show","edit","update")

      ug = @rules.set_user_group(:ug_one, :perm_one)

      @rules.should_receive(:set_model_access)
      @rules.process_rules

      @rules.access_rights_for_user_group(:ug_one).
        should == ["a_controller/show", "a_controller/edit", "a_controller/update"]
    end
  end

  describe "#access_rights_for_permission" do
    it "should return array of rights for permission" do

      perm = @rules.set_permission(:perm_one).
        with_controller("a_controller").
        only_methods("show","edit","update")

      @rules.should_receive(:set_model_access)
      @rules.process_rules

      @rules.access_rights_for_permission(perm).
        should == ["a_controller/show", "a_controller/edit", "a_controller/update"]
    end
  end

  describe "#standard_authorized_user_rights" do
    it "should receive public_access + protected_access" do
      @rules.set_permission(:register_account).
        with_controller(:users).
        only_methods(:new, :create)

      @rules.set_permission(:my_profile).
        with_controller(:users).
        only_methods(:show, :edit, :update)
      

      @rules.set_public_access(:register_account)
      @rules.set_protected_access(:my_profile)

      @rules.should_receive(:set_model_access)
      @rules.process_rules

      @rules.standard_authorized_user_rights.
        should == ["users/new", "users/create", "users/show", "users/edit", "users/update"]
    end
  end

  describe "#process_rules" do
    it "should validate user_group permissions" do
      Lockdown.should_receive(:add_controller_method)
      
      @rules.set_user_group(:test_group, :a_perm)
      error =  "User Group: test_group, permission not found: a_perm"

      lambda{@rules.process_rules}.
        should raise_error(Lockdown::InvalidRuleAssignment, error)
    end
  end
end
