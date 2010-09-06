require File.join(File.dirname(__FILE__), %w[.. .. .. spec_helper])

class TestAController
  extend Lockdown::Frameworks::Rails::Controller
  include Lockdown::Frameworks::Rails::Controller::Lock
end

describe Lockdown::Frameworks::Rails::Controller do
  before do
    @controller = TestAController

    @actions = %w(posts/index posts/show posts/new posts/edit posts/create posts/update posts/destroy)

    @lockdown = mock("lockdown")
  end

  describe "#controller_name" do
    it "should return action_methods" do
      post_controller = mock("PostController")
      post_controller.stub!(:controller_name).and_return("PostController")

      @controller.controller_name(post_controller).should == "PostController"
    end
  end

end

describe Lockdown::Frameworks::Rails::Controller::Lock do
  before do
    @controller = TestAController.new

    @actions = %w(posts/index posts/show posts/new posts/edit posts/create posts/update posts/destroy)

    @session = {:access_rights => @actions}

    @controller.stub!(:session).and_return(@session)
  end
  
  describe "#configure_lockdown" do
    it "should call Lockdown.maybe_parse_init, check_session_expiry and store_location" do
      Lockdown.should_receive(:maybe_parse_init)
      @controller.should_receive(:check_session_expiry)
      @controller.should_receive(:store_location)

      @controller.configure_lockdown
    end
  end

  describe "#set_current_user" do
    it "should set who_did_it  in Thread.current" do
      Lockdown::System.stub!(:fetch).with(:who_did_it).and_return(:current_user_id)
      @controller.stub!(:logged_in?).and_return(true)
      @controller.stub!(:current_user_id).and_return(1234)

      @controller.set_current_user

      Thread.current[:who_did_it].should == 1234
    end
  end

  describe "#check_request_authorization" do
    it "should raise SecurityError if not authorized" do
      @controller.stub!(:authorized?).and_return(false)
      @controller.stub!(:params).and_return({:p => 1})

      lambda{@controller.check_request_authorization}.
        should raise_error(SecurityError)

    end
  end

  describe "#path_allowed" do
    it "should return false for an invalid path" do
      @controller.send(:path_allowed?,"/no/good").should be_false
    end
  end

  describe "#check_session_expiry" do
    it "should set expiry if null" do
      Lockdown::System.stub!(:fetch).with(:session_timeout).and_return(10)
      @session[:expiry_time].should be_nil
      @controller.send(:check_session_expiry)
      @session[:expiry_time].should_not be_nil
    end
  end

  describe "#store_location" do
    it "should set prevpage and thispage" do
      request = mock("request")
      request.stub!(:method).and_return(:get)
      @controller.stub!(:request).and_return(request)

      @controller.stub!(:sent_from_uri).and_return("/blop")
      @controller.send(:store_location)

      @session[:prevpage].should == ''
      @session[:thispage].should == '/blop'
    end
  end

  describe "#sent_from_uri" do
    it "should return request.request_uri" do
      request = mock("request")
      request.stub!(:request_uri).and_return("/blip")

      @controller.stub!(:request).and_return(request)

      @controller.send(:sent_from_uri).should == "/blip"
    end
  end

  describe "#authorized?" do
    before do
      @sample_url = "http://stonean.com/posts/index"
      @a_path = "/a_path"

      request = mock("request")
      request.stub!(:method).and_return(:get)
      Lockdown.stub(:caching?).and_return(true)
      @controller.stub!(:params).and_return({})
      @controller.stub!(:request).and_return(request)

      stonean_parts = ["http", nil, "stonean.com", nil, nil, "posts/index", nil, nil, nil]

      a_path_parts = [nil, nil, nil, nil, nil, "/a_path", nil, nil, nil]

      URI = mock('uri class') unless defined?(URI)
      URI.stub!(:split).with(@sample_url).and_return(stonean_parts)
      URI.stub!(:split).with(@a_path).and_return(a_path_parts)
    end

    it "should call add_lockdown_session_values unless caching" do
      Lockdown.stub(:caching?).and_return(false)
      @controller.should_receive(:add_lockdown_session_values)

      @controller.send(:authorized?,nil)
    end

    it "should return false if url is nil" do
      @controller.send(:authorized?,nil).should be_false
    end

    it "should return true if current_user_is_admin" do
      @controller.stub!(:current_user_is_admin?).and_return(true)
      @controller.send(:authorized?,@a_path).should be_true
    end

    it "should return false if path not in access_rights" do
      @controller.send(:authorized?,@a_path).should be_false
    end

    it "should return true if path is in access_rights" do
      @controller.send(:authorized?,@sample_url).should be_true
    end

  end

  describe "#access_denied" do
  end

  describe "#path_from_hash" do
    it "should return controller/action string" do
      hash = {:controller => "users", :action => "show", :id => "1"}
      @controller.send(:path_from_hash,hash).should == "users/show"
    end
  end

  describe "#remote_url?" do
    it "should return false if domain is nil" do
      @controller.send(:remote_url?).should be_false
    end

    it "should return false if domain matches request domain" do
      request = mock("request")
      request.stub!(:host).and_return("stonean.com")
      @controller.stub!(:request).and_return(request)
      @controller.send(:remote_url?,"stonean.com").should be_false
    end

    it "should return true if subdomain differs" do
      request = mock("request")
      request.stub!(:host).and_return("blog.stonean.com")
      @controller.stub!(:request).and_return(request)
      @controller.send(:remote_url?,"stonean.com").should be_true
    end

    it "should return true if host doesn't match  domain" do
      request = mock("request")
      request.stub!(:host).and_return("stonean.com")
      @controller.stub!(:request).and_return(request)
      @controller.send(:remote_url?,"google.com").should be_true
    end
  end

  describe "#redirect_back_or_default" do
    it "should redirect to default without session[:prevpage]" do
      @controller.should_receive(:redirect_to).with("/")
      @controller.send :redirect_back_or_default, "/"
    end

    it "should redirect to session[:prevpage]" do
      path = "/previous"
      path.stub!(:blank?).and_return(false)
      @session[:prevpage] = path
      @controller.should_receive(:redirect_to).with(path)
      @controller.send :redirect_back_or_default, "/"
    end
  end

  describe "#login_from_basic_auth?" do
  end

  describe "#get_auth_data" do
  end
end
