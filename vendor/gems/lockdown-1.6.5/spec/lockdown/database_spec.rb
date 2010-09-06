require File.join(File.dirname(__FILE__), %w[.. spec_helper])

class Permission; end;

describe Lockdown::Database do
  before do    
    Lockdown::System.stub!(:get_permissions).and_return([:permission])
    Lockdown::System.stub!(:get_user_groups).and_return([:user_group])
    @user_group_class = mock(:table_exists? => true, :find => false)
    Lockdown.stub!(:user_group_class).and_return @user_group_class

  end

  describe "#sync_with_db" do
    it "should call create_new_permissions, delete_extinct_permissions and maintain_user_groups" do
      Permission.stub!(:table_exists?).and_return(true)
      Lockdown::Database.should_receive :create_new_permissions
      Lockdown::Database.should_receive :delete_extinct_permissions
      Lockdown::Database.should_receive :maintain_user_groups

      Lockdown::Database.sync_with_db
    end
  end

  describe "#create_new_permissions" do
    it "should create permission from @permissions" do
      Lockdown::System.stub!(:permission_assigned_automatically?).and_return(false)

      Permission.stub!(:find).and_return(false)
      Permission.should_receive(:create).with(:name => 'Permission')

      Lockdown::Database.create_new_permissions
    end
  end

  describe "#delete_extinct_permissions" do
    it "should create permission from @permissions" do
      permission = mock('permission')
      permission.stub!(:id).and_return("3344")
      permission.stub!(:name).and_return("sweet permission")
      permissions = [permission]

      Permission = mock('Permission') unless defined?(Permission)
      Permission.stub!(:find).with(:all).and_return(permissions)

      Lockdown.should_receive(:database_execute).
        with("delete from permissions_user_groups where permission_id = 3344")
      permission.should_receive(:destroy)

      Lockdown::Database.delete_extinct_permissions
    end
  end

  describe "#maintain_user_groups" do
    before do
      UserGroup = mock('UserGroup') unless defined?(UserGroup)
    end

    it "should create user group for non-existent user group" do
      @user_group_class.should_receive(:find).and_return(false)
      
      Lockdown::Database.should_receive(:create_user_group).
        with("User Group",:user_group)

      Lockdown::Database.maintain_user_groups
    end

    it "should sync user group permissions for existing user group" do
      ug = mock('user group')

      @user_group_class.should_receive(:find).
        with(:first, :conditions => ["name = ?", "User Group"]).
        and_return(ug)
      
      Lockdown::Database.should_receive(:remove_invalid_permissions).
        with(ug,:user_group)

      Lockdown::Database.should_receive(:add_valid_permissions).
        with(ug,:user_group)

      Lockdown::Database.maintain_user_groups
    end
  end

  describe "#create_user_group" do
    it "should create new user group" do
      ug = mock('user group')
      ug.stub!(:id).and_return(123)

      @user_group_class.should_receive(:create).
        with(:name => "some group").
        and_return(ug)

      Lockdown::System.stub!(:permissions_for_user_group).
        and_return([:perm])

      Lockdown::System.stub!(:permission_assigned_automatically?).
        and_return(false)

      perm = mock('permission')
      perm.stub!(:id).and_return(3344)

      Permission = mock('Permission') unless defined?(Permission)

      Permission.should_receive(:find).
        with(:first, :conditions => ["name = ?",'Perm']).
        and_return(perm)

      Lockdown.should_receive(:database_execute).
        with("insert into permissions_user_groups(permission_id, user_group_id) values(3344, 123)")

      Lockdown::Database.create_user_group("some group",  :some_group)
    end
  end

  describe "#remove_invalid_permissions" do
    it "should remove permissions that no longer exist" do
      permissions = [:good_perm, :bad_perm]

      user_group = mock("user group", :name => "user group")

      #returns what's in the database
      user_group.stub!(:permissions).and_return(permissions)

      #return what's defined in init.rb
      Lockdown::System.stub!(:permissions_for_user_group).
        and_return([:good_perm])

      #delete what's not in init.rb 
      permissions.should_receive(:delete).with(:bad_perm)

      Lockdown::Database.remove_invalid_permissions(user_group, :user_group)
    end
  end

  describe "#add_invalid_permissions" do
    it "should add permissions that are defined in init.rb" do
      #return what's defined in init.rb
      Lockdown::System.stub!(:permissions_for_user_group).
        and_return([:defined_perm, :undefined_perm])

      permissions = [:defined_perm]

      user_group = mock("user group", :name => "user group")

      #returns what's in the database
      user_group.stub!(:permissions).and_return(permissions)

      Permission = mock('Permission') unless defined?(Permission)

      #get the permission object for the undefined_perm
      Permission.should_receive(:find).
        with(:first, :conditions => ["name = ?",'Undefined Perm']).
        and_return(:undefined_perm)

      #add the perm to the user group
      permissions.should_receive(:<<).with(:undefined_perm)

      Lockdown::Database.add_valid_permissions(user_group, :user_group)
    end
  end
end
