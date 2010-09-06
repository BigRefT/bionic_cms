module Lockdown
  module RspecHelper
    def self.included(mod)
      Lockdown.maybe_parse_init
    end

    def login_admin
      login_user(:admin)
    end

    def login_with_groups(*user_group_symbols)
      access_rights = Lockdown::System.standard_authorized_user_rights
      user_group_symbols.each do |ugs|
        access_rights << Lockdown::System.access_rights_for_user_group(ugs)
      end
      login_user
      controller.session[:access_rights] = access_rights.flatten
    end

    alias login_with_group login_with_groups 

    def login_with_permissions(*permissions_symbols)
      access_rights = Lockdown::System.standard_authorized_user_rights
      permissions_symbols.each do |ps|
        access_rights << Lockdown::System.access_rights_for_permission(ps)
      end
      login_user
      controller.session[:access_rights] = access_rights.flatten.uniq
    end
    
    alias login_with_permission login_with_permissions    

    def login_standard
      login_user
    end

    def public_user
      setup_public_user
    end


    private

    def login_user(user_type = :standard)
      initialize_user(user_type)

      create_user_session

      controller.stub!(:current_user).and_return(@current_user)
    end

    def setup_public_user
      controller.session[:access_rights] = Lockdown::System.public_access
    end

    def all_actions(hash = {})
      methods = controller.send :action_methods

      if excepts = hash.delete(:except)
        excepts = Array.new(excepts)
        methods.reject!{|m| excepts.include?(m.to_sym)}
      end

      Lockdown::System.paths_for(controller.controller_name,methods.to_a).sort
    end

    def only_actions(*actions)
      Lockdown::System.paths_for(controller.controller_name,actions).sort
    end

    def allowed_actions
      if rights = controller.session[:access_rights]
        if rights == :all
          all_actions
        else
          name = controller.controller_name
          rights.collect{|r| r if r =~ /^#{name}\// || r == name}.compact.sort
        end
      else
        []
      end
    end

    def initialize_user(user_type)
      @current_user = mock_user

      if user_type == :admin
        set_user_group(Lockdown.administrator_group_symbol)
      end
    end

    # You may want to override this method
    def mock_user
      mock_model  User,
                  :user_groups => [],
                  :first_name => 'John',
                  :last_name  => 'Smith',
                  :password   => "mysecret",
                  :password_confirmation   => "mysecret"
    end

    def create_user_session
      controller.send :add_lockdown_session_values, @current_user
    end

    # Lockdown.convert_reference_name converts :users to "Users" 
    def set_user_group(sym)
      user_group = mock_user_group
      user_group.stub!(:name).and_return( Lockdown.convert_reference_name(sym) )
      @current_user.stub!(Lockdown.user_groups_hbtm_reference).and_return([user_group])
    end

    # You may want to override this method
    def mock_user_group
      mock_model(UserGroup)
    end
  end
end
