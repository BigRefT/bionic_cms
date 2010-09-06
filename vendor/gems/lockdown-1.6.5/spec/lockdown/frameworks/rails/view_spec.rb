require File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper])

class TestAView
  def link_to
    "link_to"
  end

  def button_to
    "button_to"
  end

  include Lockdown::Frameworks::Rails::View
end

describe Lockdown::Frameworks::Rails::Controller do

  before do
    @view = TestAView.new

    @view.stub!(:url_for).and_return("posts/new")

    @options = {:controller => "posts", :action => "new"}
  end

  describe "#link_to_secured" do
    it "should return the link if authorized" do
      link = "<a href='http://a.com'>my_link</a>"
      @view.stub!(:authorized?).and_return(true)
      @view.stub!(:link_to_open).and_return(link)

      @view.link_to_secured("my link", @options).should == link
    end

     it "should return an empty string if authorized" do
      @view.stub!(:authorized?).and_return(false)

      @view.link_to_secured("my link", @options).should == ""
    end

    it 'should use the default "get" when html_options[:method] is nil' do
      link = "<a href='http://a.com'>my_link</a>"

      @view.should_receive(:authorized?).with('posts/new', :get)

      @view.link_to_secured("my link", @options, {})
    end
  end

  describe "#button_to_secured" do
    it "should return the link if authorized" do
      link = "<a href='http://a.com'>my_link</a>"
      @view.stub!(:authorized?).and_return(true)
      @view.stub!(:button_to_open).and_return(link)

      @view.button_to_secured("my link", @options).should == link
    end

     it "should return an empty string if authorized" do
      @view.stub!(:authorized?).and_return(false)

      @view.button_to_secured("my link", @options).should == ""
    end
  end

  describe "#link_to_or_show" do
    it "should return the name if link_to returned an empty string" do
      @view.stub!(:link_to).and_return('')

      @view.link_to_or_show("my_link", @options).
        should == "my_link"
    end

    it "should return the link if access is allowed" do
      link = "<a href='http://a.com'>my_link</a>"
      @view.stub!(:link_to).and_return(link)

      @view.link_to_or_show("my_link", @options).
        should == link
    end
  end

  describe "#link_to_or_show" do
    it "should return links separated by | " do
      Lockdown::System.stub!(:fetch).with(:link_separator).and_return(' | ')
      links = ["link_one", "link_two"]
      @view.links(links).should == links.join(' | ')
    end

    it "should return links separated by | and handle empty strings" do
      Lockdown::System.stub!(:fetch).with(:link_separator).and_return(' | ')
      links = ["link_one", "link_two", ""]
      @view.links(links).should == links.join(' | ')
    end
  end
end

