ActionController::Routing::Routes.draw do |map|

  map.login '/login', :controller => 'home', :action => 'show_login_page'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.begin_draft_mode '/begin_draft_mode', :controller => 'home', :action => 'toggle_draft_mode', :mode => 'draft'
  map.end_draft_mode '/end_draft_mode', :controller => 'home', :action => 'toggle_draft_mode', :mode => 'live'
  map.dashboard_admin '/admin', :controller => 'admin/dashboard', :action => 'index'

  map.user_update '/forms/user/update/:id', :controller => 'customer', :action => 'update_user', :conditions => { :method => :post }
  map.profile_update '/forms/profile/update/:id', :controller => 'customer', :action => 'update_profile', :conditions => { :method => :post }
  map.contact '/forms/contact', :controller => 'home', :action => 'contact'

  map.resources :sessions, :except => [:index]

  map.namespace :admin do |admin|
    admin.resources :dashboard
    admin.resources :permissions
    admin.resources :profiles,
                    :member => { :enable => :get, :disable => :get }
    admin.resources :user_groups
    admin.resources :sites, :collection => { :filter_site => :post }
    admin.resources :site_layouts, :member => { :start_draft => :post, :publish_draft => :post, :live_content => :get }
    admin.resources :site_pages,
                    :collection => {:search => :get, :show_tree => :get},
                    :member => {
                      :add_site_route => :post,
                      :update_user_groups => :post,
                      :children => :get,
                      :update_parts => :put
                    } do |site_pages|
      site_pages.resources :site_page_parts, :as => 'parts',
                           :only => [ :new, :create, :edit, :update, :destroy ],
                           :member => { :start_draft => :post, :publish_draft => :post, :live_content => :get }
    end
    admin.resources :site_snippets, :member => { :start_draft => :post, :publish_draft => :post, :live_content => :get }
    admin.resources :site_routes
    admin.resources :site_assets,
                    :member => { :decompress => :get },
                    :except => [:new, :show]
    admin.resources :site_emails, :member => { :activate => :get, :deactivate => :get }
    admin.resources :custom_notifiers, :only => [ :new, :create ]

    admin.resources :site_menus,
                    :member => { :order => :post, :draft => :post, :publish => :post, :live_content => :get },
                    :only => [ :index, :new, :create, :destroy ] do |site_menus|
      site_menus.resources :site_menu_items, :as => 'links', :except => [:index, :show]
    end

    admin.with_options(:controller => :extensions) do |extension|
      extension.extensions 'extensions', :action => 'index'
    end
  end
  # Everything else
  map.home '', :controller => 'home', :action => 'show_page', :url => '/'
  map.connect '*url', :controller => 'home', :action => 'show_page'
end
