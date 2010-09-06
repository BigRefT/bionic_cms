require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Lockdown::Permission do
  before do
    
    @permission = Lockdown::Permission.new(:user_management)
    @permission.stub!(:paths_for).and_return([])
  end

  describe "#with_controller" do
    before do
      @permission.with_controller(:users)
    end

    it "should set current_context to ControllerContext" do
      @permission.current_context.class.should equal(Lockdown::ControllerContext)
    end
  end

  describe "#only_methods" do
    before do
      @permission.with_controller(:users).only_methods(:show, :edit)
    end

    it "should set current_context to RootContext" do
      @permission.current_context.class.should equal(Lockdown::RootContext)
    end
  end

  describe "#except_methods" do
    before do
      @permission.with_controller(:users).except_methods(:destroy)
    end

    it "should set current_context to RootContext" do
      @permission.current_context.class.should equal(Lockdown::RootContext)
    end
  end

  describe "#to_model" do
    before do
      @permission.to_model(:user)
    end

    it "should set current_context to ModelContext" do
      @permission.current_context.class.should equal(Lockdown::ModelContext)
    end
  end

  describe "#where" do
    before do
      @permission.to_model(:user).where(:current_user_id)
    end

    it "should set current_context to ModelWhereContext" do
      @permission.current_context.class.should equal(Lockdown::ModelWhereContext)
    end
  end

  describe "#equals" do
    before do
      @permission.to_model(:user).where(:current_user_id).equals(:id)
    end

    it "should set current_context to RootContext" do
      @permission.current_context.class.should equal(Lockdown::RootContext)
    end
  end

  describe "#is_in" do
    before do
      @permission.to_model(:user).where(:current_user_id).is_in(:manager_ids)
    end

    it "should set current_context to RootContext" do
      @permission.current_context.class.should equal(Lockdown::RootContext)
    end
  end

  describe "#set_as_public_access" do
    it "should raise an PermissionScopeCollision if already protected" do
      @permission.set_as_protected_access
      lambda{@permission.set_as_public_access}.
        should raise_error(Lockdown::PermissionScopeCollision)
    end
  end


  describe "#set_as_protected_access" do
    it "should raise an PermissionScopeCollision if already public" do
      @permission.set_as_public_access
      lambda{@permission.set_as_protected_access}.
        should raise_error(Lockdown::PermissionScopeCollision)
    end
  end

  describe "while in RootContext" do
    before do
      @permission.with_controller(:users).only_methods(:show, :edit)
    end

    it "should raise InvalidRuleContext trying to access methods out of context" do
      methods = [:only_methods, :except_methods, :where, :equals, :is_in, :includes]

        methods.each do |method|
          lambda{@permission.send(method, :sample_param)}.
            should raise_error(Lockdown::InvalidRuleContext)
        end
    end
  end

  describe "while in ControllerContext" do
    before do
      @permission.with_controller(:users)
    end

    it "should raise InvalidRuleContext trying to access methods out of context" do
      methods = [:where, :equals, :is_in, :includes]

        methods.each do |method|
          lambda{@permission.send(method, :sample_param)}.
            should raise_error(Lockdown::InvalidRuleContext)
        end
    end
  end

  describe "while in ModelContext" do
    before do
      @permission.to_model(:user)
    end

    it "should raise InvalidRuleContext trying to access methods out of context" do
      methods = [:with_controller, :and_controller, :only_methods, :except_methods, :to_model, :equals, :is_in, :includes]

        methods.each do |method|
          lambda{@permission.send(method, :sample_param)}.
            should raise_error(Lockdown::InvalidRuleContext)
        end
    end
  end

  describe "while in ModelWhereContext" do
    before do
      @permission.to_model(:user).where(:current_user_id)
    end

    it "should raise InvalidRuleContext trying to access methods out of context" do
      methods = [:with_controller, :and_controller, :only_methods, :except_methods, :to_model, :where]

        methods.each do |method|
          lambda{@permission.send(method, :sample_param)}.
            should raise_error(Lockdown::InvalidRuleContext)
        end
    end
  end
end
