require File.join(File.dirname(__FILE__), 'spec_helper')

describe Lockdown do
  before do
    Lockdown.stub!(:version).and_return('1.2.3')
  end

  it "should return the correct major version" do
    Lockdown.major_version.should equal(1)
  end

  it "should return the correct minor version" do
    Lockdown.minor_version.should equal(2)
  end

  it "should return the correct patch version" do
    Lockdown.patch_version.should equal(3)
  end
end
