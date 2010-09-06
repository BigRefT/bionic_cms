require 'test_helper'

class TestRecord < ActiveRecord::Base
  def self.columns; []; end
  attr_accessor :temp
  validates_proper_liquid_syntax :temp
end

class ValidatesProperLiquidSyntaxTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  context 'validates proper liquid syntax' do
    context 'with out closed brackets' do
      setup do
        @rec = TestRecord.new(:temp => '<div>{{ hello</div>')
      end
      should "throw an improper parse error" do
        @rec.valid?.should == false
        @rec.errors[:temp].should_not be_nil
        @rec.errors[:temp]['was not properly terminated'].should_not be_nil
      end
    end
    context 'with closed brackets' do
      setup do
        @rec = TestRecord.new(:temp => '<div>{{ hello }}</div>')
      end
      should "not throw an improper parse error" do
        @rec.valid?.should == true
        @rec.errors[:temp].should be_nil
      end
    end
    context 'with unclosed tag syntax' do
      setup do
        @rec = TestRecord.new(:temp => '{% if true %}<div>{{ hello }}</div>')
      end
      should "throw an improper parse error" do
        @rec.valid?.should == false
        @rec.errors[:temp].should_not be_nil
        @rec.errors[:temp]['if tag was never closed'].should_not be_nil
      end
    end  
  end  
end
