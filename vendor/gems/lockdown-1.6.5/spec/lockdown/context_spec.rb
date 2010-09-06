require File.join(File.dirname(__FILE__), %w[.. spec_helper])

describe Lockdown::Context do
  before do
    @name = :my_account
  end

  describe Lockdown::RootContext do
    before do
      @c = Lockdown::RootContext.new(@name)
    end

    it "should return rootcontext" do
      @c.to_s.should == "Lockdown::RootContext"
    end

    it "should allow with_controller" do
      @c.allows?('with_controller').should == true
    end

    it "should allow and_controller" do
      @c.allows?('and_controller').should == true
    end

    it "should allow to_model" do
      @c.allows?('to_model').should == true
    end

    it "should not allow only_methods" do
      @c.allows?('only_methods').should == false
    end

    it "should not allow except_methods" do
      @c.allows?('except_methods').should == false
    end

    it "should not allow where" do
      @c.allows?('where').should == false
    end

    it "should not allow is_in" do
      @c.allows?('is_in').should == false
    end

    it "should not allow includes" do
      @c.allows?('includes').should == false
    end

    it "should not allow equals" do
      @c.allows?('equals').should == false
    end
  end

  describe Lockdown::ControllerContext do
    before do
      @c = Lockdown::ControllerContext.new(@name)
    end

    it "should return rootcontext" do
      @c.to_s.should == "Lockdown::ControllerContext"
    end

    it "should allow with_controller" do
      @c.allows?('with_controller').should == true
    end

    it "should allow and_controller" do
      @c.allows?('and_controller').should == true
    end

    it "should allow to_model" do
      @c.allows?('to_model').should == true
    end

    it "should allow only_methods" do
      @c.allows?('only_methods').should == true
    end

    it "should allow except_methods" do
      @c.allows?('except_methods').should == true
    end

    it "should not allow where" do
      @c.allows?('where').should == false
    end

    it "should not allow is_in" do
      @c.allows?('is_in').should == false
    end

    it "should not allow includes" do
      @c.allows?('includes').should == false
    end

    it "should not allow equals" do
      @c.allows?('equals').should == false
    end
  end 

  describe Lockdown::ModelContext do
    before do
      @c = Lockdown::ModelContext.new(@name)
    end

    it "should return rootcontext" do
      @c.to_s.should == "Lockdown::ModelContext"
    end

    it "should not allow with_controller" do
      @c.allows?('with_controller').should == false
    end

    it "should not allow and_controller" do
      @c.allows?('and_controller').should == false
    end

    it "should not allow to_model" do
      @c.allows?('to_model').should == false
    end

    it "should not allow only_methods" do
      @c.allows?('only_methods').should == false
    end

    it "should not allow except_methods" do
      @c.allows?('except_methods').should == false
    end

    it "should allow where" do
      @c.allows?('where').should == true
    end

    it "should not allow is_in" do
      @c.allows?('is_in').should == false
    end

    it "should not allow includes" do
      @c.allows?('includes').should == false
    end

    it "should not allow equals" do
      @c.allows?('equals').should == false
    end
  end 

  describe Lockdown::ModelWhereContext do
    before do
      @c = Lockdown::ModelWhereContext.new(@name)
    end

    it "should return rootcontext" do
      @c.to_s.should == "Lockdown::ModelWhereContext"
    end

    it "should not allow with_controller" do
      @c.allows?('with_controller').should == false
    end

    it "should not allow and_controller" do
      @c.allows?('and_controller').should == false
    end

    it "should not allow to_model" do
      @c.allows?('to_model').should == false
    end

    it "should not allow only_methods" do
      @c.allows?('only_methods').should == false
    end

    it "should not allow except_methods" do
      @c.allows?('except_methods').should == false
    end

    it "should not allow where" do
      @c.allows?('where').should == false
    end

    it "should allow is_in" do
      @c.allows?('is_in').should == true
    end

    it "should allow includes" do
      @c.allows?('includes').should == true
    end

    it "should allow equals" do
      @c.allows?('equals').should == true
    end
  end 
end
