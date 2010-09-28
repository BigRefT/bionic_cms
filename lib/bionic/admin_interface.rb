# general idea from Radiant CMS => http://www.radiant.org

require 'singleton'
require 'ostruct'

module Bionic
  class AdminInterface
    # This may be loaded before ActiveSupport, so do an explicit require
    require 'bionic/admin_interface/menu_set'
    require 'bionic/admin_interface/menu'
    require 'bionic/admin_interface/menu_item'

    include Singleton

    attr_reader :navigation

    def initialize
      clear_menus
    end

    def clear_menus
      @navigation = MenuSet.new
    end

    # Region sets
    %w{custom_notifier dashboard extension permission profile site_asset site_email site_layout site_menu site_menu_item site_page site_page_part site_route site_snippet site user_group}.each do |controller|
      attr_accessor controller
      alias_method "#{controller}s", controller
    end

    def load_default_interface
      clear_menus
      load_default_menus
      load_default_regions
    end

    def load_default_menus
      @navigation.add("Dashboard", "/admin")
      handle = @navigation.add("Site Management", "#")
      @navigation.send(handle.to_sym).add("Sites", "/admin/sites")
      @navigation.send(handle.to_sym).add("Site Menus", "/admin/site_menus")
      @navigation.send(handle.to_sym).add("Site Layouts", "/admin/site_layouts")
      @navigation.send(handle.to_sym).add("Site Snippets", "/admin/site_snippets")
      @navigation.send(handle.to_sym).add("Site Pages", "/admin/site_pages")
      @navigation.send(handle.to_sym).add("Site Emails", "/admin/site_emails")
      @navigation.send(handle.to_sym).add("Site Assets", "/admin/site_assets")
      @navigation.send(handle.to_sym).add("Site Routes", "/admin/site_routes")
      handle = @navigation.add("User Management", "#")
      @navigation.send(handle.to_sym).add("Permissions", "/admin/permissions")
      @navigation.send(handle.to_sym).add("User Groups", "/admin/user_groups")
      @navigation.send(handle.to_sym).add("Users", "/admin/profiles")
    end

    def load_default_regions
      @custom_notifier = load_default_custom_notifier_regions
      @dashboard = load_default_dashboard_regions
      @extension = load_default_extension_regions
      @permission = load_default_permission_regions
      @profile = load_default_profile_regions
      @site_asset = load_default_site_asset_regions
      @site_email = load_default_site_email_regions
      @site_layout = load_default_site_layout_regions
      @site_menu = load_default_site_menu_regions
      @site_menu_item = load_default_site_menu_item_regions
      @site_page = load_default_site_page_regions
      @site_page_part = load_default_site_page_part_regions
      @site_route = load_default_site_route_regions
      @site_snippet = load_default_site_snippet_regions
      @site = load_default_site_regions
      @user_group = load_default_user_group_regions
    end

    private

    def load_default_custom_notifier_regions
      returning OpenStruct.new do |custom_notifier|
        custom_notifier.new = RegionSet.new do |new|
          new.main.concat %w{edit_form}
          new.form_top.concat %w{edit_errors}
          new.form.concat %w{edit_type edit_name}
          new.form_bottom.concat %w{edit_buttons}
          new.right_side.concat %w{}
        end
      end
    end

    def load_default_dashboard_regions
      returning OpenStruct.new do |dashboard|
        dashboard.index = RegionSet.new do |index|
          index.top.concat %w{pagination_counts}
          index.before_list.concat %w{}
          index.list_headers.concat %w{name_column_header website_column_header version_column_header}
          index.list_data.concat %w{name_column website_column version_column}
          index.after_list.concat %w{pagination_links}
          index.action_row.concat %w{}
          index.bottom.concat %w{}
          index.right_side.concat %w{}
        end
      end
    end

    def load_default_extension_regions
      returning OpenStruct.new do |extension|
        extension.index = RegionSet.new do |index|
          index.top.concat %w{}
          index.before_list.concat %w{}
          index.list_headers.concat %w{name_column_header website_column_header version_column_header}
          index.list_data.concat %w{name_column website_column version_column}
          index.after_list.concat %w{pagination_links}
          index.action_row.concat %w{}
          index.bottom.concat %w{}
          index.right_side.concat %w{}
        end
      end
    end

    def load_default_permission_regions
      returning OpenStruct.new do |extension|
        extension.index = RegionSet.new do |index|
          index.top.concat %w{pagination_counts}
          index.before_list.concat %w{}
          index.list_headers.concat %w{name_column_header user_groups_column_header}
          index.list_data.concat %w{name_column user_groups_column}
          index.after_list.concat %w{pagination_links}
          index.action_row.concat %w{}
          index.bottom.concat %w{}
          index.right_side.concat %w{}
        end
      end
    end

    def load_default_profile_regions
      returning OpenStruct.new do |profile|
        profile.index = RegionSet.new do |index|
          index.top.concat %w{pagination_counts}
          index.before_list.concat %w{}
          index.list_headers.concat %w{email_column_header name_column_header has_account_column_header user_groups_column_header actions_column_header site_column_header}
          index.list_data.concat %w{email_column name_column has_account_column user_groups_column actions_column site_column}
          index.after_list.concat %w{pagination_links}
          index.action_row.concat %w{new_user}
          index.bottom.concat %w{}
          index.right_side.concat %w{search user_group_search}
          index.right_side_advanced_search_fields.concat %w{search_per_page search_buttons}
        end
        profile.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_email edit_email_confirmation edit_first_name edit_last_name edit_user_fields}
          edit.user_fields.concat %w{edit_login edit_password edit_password_confirmation edit_user_groups}
          edit.form_bottom.concat %w{edit_buttons}
          edit.right_side.concat %w{profile_history}
        end
        profile.new = RegionSet.new do |new|
          new.main.concat %w{edit_form}
          new.form_top.concat %w{edit_errors}
          new.form.concat %w{edit_email edit_email_confirmation edit_first_name edit_last_name edit_user_fields}
          new.user_fields.concat %w{edit_login edit_password edit_password_confirmation edit_user_groups}
          new.form_bottom.concat %w{edit_buttons}
          new.right_side.concat %w{}
        end
      end
    end

    def load_default_site_asset_regions
      returning OpenStruct.new do |site_asset|
        site_asset.index = RegionSet.new do |index|
          index.top.concat %w{tooltip_script pagination_counts}
          index.before_list.concat %w{}
          index.list_headers.concat %w{icon_column_header name_column_header urls_column_header actions_column_header}
          index.list_data.concat %w{icon_column name_column urls_column actions_column}
          index.after_list.concat %w{pagination_links}
          index.action_row.concat %w{index_form}
          index.index_form_top.concat %w{edit_index_errors}
          index.index_form.concat %w{edit_index_filename edit_index_display_name edit_index_tags }
          index.index_form_bottom.concat %w{edit_index_buttons}
          index.bottom.concat %w{}
          index.right_side.concat %w{search quick_search tag_cloud}
        end
        site_asset.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_area_script edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_display_name edit_filename edit_tags edit_content}
          edit.form_bottom.concat %w{edit_buttons}
          edit.right_side.concat %w{}
        end
      end
    end

    def load_default_site_email_regions
      returning OpenStruct.new do |site_email|
        site_email.index = RegionSet.new do |index|
          index.top.concat %w{}
          index.before_list.concat %w{}
          index.tab_header.concat %w{system_notifier_tab_header custom_notifier_tab_header}
          index.tabs.concat %w{system_notifier_tab custom_notifier_tab}

          index.system_before_list.concat %w{}
          index.system_list_headers.concat %w{system_notifier_column_header system_actions_column_header}
          index.system_list_data.concat %w{system_notifier_column system_actions_column}
          index.system_after_list.concat %w{}
          index.system_action_row.concat %w{}

          index.custom_before_list.concat %w{}
          index.custom_list_headers.concat %w{custom_notifier_column_header custom_actions_column_header}
          index.custom_list_data.concat %w{custom_notifier_column custom_actions_column}
          index.custom_after_list.concat %w{pagination_links}
          index.custom_action_row.concat %w{new_custom_notifier}

          index.after_list.concat %w{}
          index.bottom.concat %w{tab_javascript}
          index.right_side.concat %w{}
        end
        site_email.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_notifier edit_number_of_days edit_active edit_subject edit_to_or_from edit_cc edit_bcc edit_reply_to edit_content_type edit_snippet_id edit_misc_data}
          edit.form_bottom.concat %w{edit_buttons}
          edit.right_side.concat %w{}
        end
        site_email.new = site_email.edit
      end
    end

    def load_default_site_layout_regions
      returning OpenStruct.new do |site_layout|
        site_layout.index = RegionSet.new do |index|
          index.top.concat %w{pagination_counts}
          index.before_list.concat %w{}
          index.list_headers.concat %w{name_column_header content_type_column_header actions_column_header}
          index.list_data.concat %w{name_column content_type_column actions_column}
          index.after_list.concat %w{pagination_links}
          index.action_row.concat %w{new_site_layout}
          index.bottom.concat %w{}
          index.right_side.concat %w{search help}
        end
        site_layout.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_name edit_content}
          edit.form_bottom.concat %w{edit_buttons}
          edit.right_side.concat %w{help}
        end
        site_layout.new = site_layout.edit
        site_layout.live_content = RegionSet.new do |live_content|
          live_content.live_main.concat %w{edit_area_settings live_content}
        end
      end
    end

    def load_default_site_menu_regions
      returning OpenStruct.new do |site_menu|
        site_menu.index = RegionSet.new do |index|
          index.action_row.concat %w{new_site_menu}
          index.menu_list.concat %w{site_menus}
          index.menu_top.concat %w{break}
          index.before_item_list.concat %w{}
          index.item_list.concat %w{actions_column name_column url_column}
          index.after_item_list.concat %w{sortable_javascript pagination_links}
          index.menu_action_row.concat %w{new_menu_link draft_links remove_site_menu}
          index.menu_bottom.concat %w{}
          index.right_side.concat %w{}
        end
        site_menu.new = RegionSet.new do |new|
          new.main.concat %w{edit_form}
          new.form_top.concat %w{edit_errors}
          new.form.concat %w{edit_name}
          new.form_bottom.concat %w{edit_buttons}
          new.right_side.concat %w{}
        end
        site_menu.live_content = RegionSet.new do |live_content|
          live_content.live_main.concat %w{live_item_list}
          live_content.live_list.concat %w{live_name_column live_arrow_column live_url_column}
        end
      end
    end

    def load_default_site_menu_item_regions
      returning OpenStruct.new do |site_menu_item|
        site_menu_item.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_name edit_site_route edit_redirect_url edit_site_menu_id}
          edit.form_bottom.concat %w{edit_buttons}
          edit.right_side.concat %w{}
        end
        site_menu_item.new = site_menu_item.edit
      end
    end

    def load_default_site_page_regions
      returning OpenStruct.new do |site_page|
        site_page.index = RegionSet.new do |index|
          index.top.concat %w{}
          index.before_list.concat %w{}
          index.list_headers.concat %w{title_column_header type_column_header status_column_header actions_column_header}
          index.list_data.concat %w{title_column type_column status_column actions_column}
          index.after_list.concat %w{}
          index.action_row.concat %w{new_home_page}
          index.right_side.concat %w{search_common right_theme_pages}
        end
        site_page.children = site_page.index
        site_page.search = RegionSet.new do |search|
          search.search_top.concat %w{pagination_counts}
          search.search_before_list.concat %w{}
          search.search_headers.concat %w{search_title_column_header search_url_column_header search_type_column_header search_status_column_header search_actions_column_header}
          search.search_list_data.concat %w{search_title_column search_url_column search_type_column search_status_column search_actions_column}
          search.search_after_list.concat %w{pagination_links}
          search.search_bottom.concat %w{}
          search.right_side.concat %w{search_common}
        end
        site_page.show = RegionSet.new do |show|
          show.above_content.concat %w{action_list}
          show.tab_header.concat %w{general_tab_header}
          show.tabs.concat %w{general_tab}

          show.general_list_content.concat %w{show_data content_form_header content_form}
          show.general_data.concat %w{data_standard}
          show.general_content_form_top.concat %w{}
          show.general_content_form.concat %w{content_name_tabs content_form_editor}
          show.general_content_form_bottom.concat %w{content_form_buttons general_tabs_javascript}
          show.general_content_form_part_actions.concat %w{draft_part edit_part delete_part}

          show.below_content.concat %w{show_additional_script}
          show.right_side.concat %w{page_routes user_access_groups}
        end
        site_page.update_parts = site_page.show
        site_page.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_name edit_extended_metadata edit_layout_and_type edit_options}
          edit.form_bottom.concat %w{edit_buttons}
          edit.right_side.concat %w{page_routes user_access_groups}
        end
        site_page.new = RegionSet.new do |new|
          new.main.concat %w{edit_form}
          new.form_top.concat %w{edit_errors}
          new.form.concat %w{edit_name edit_extended_metadata edit_layout_and_type edit_options}
          new.form_bottom.concat %w{edit_buttons}
          new.right_side.concat %w{}
        end
      end
    end

    def load_default_site_page_part_regions
      returning OpenStruct.new do |site_page_part|
        site_page_part.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_name edit_content_type}
          edit.form_bottom.concat %w{edit_buttons}
          edit.right_side.concat %w{}
        end
        site_page_part.new = site_page_part.edit
        site_page_part.live_content = RegionSet.new do |live_content|
        end
        site_page_part.live_content = RegionSet.new do |live_content|
          live_content.live_main.concat %w{edit_area_settings live_content}
        end
      end
    end

    def load_default_site_route_regions
      returning OpenStruct.new do |user_route|
        user_route.index = RegionSet.new do |index|
          index.top.concat %w{pagination_counts}
          index.before_list.concat %w{}
          index.list_headers.concat %w{url_handle_column_header arrow_column_header site_page_column_header actions_column_header}
          index.list_data.concat %w{url_handle_column arrow_column site_page_column actions_column}
          index.after_list.concat %w{pagination_links}
          index.action_row.concat %w{new_site_route}
          index.bottom.concat %w{}
          index.right_side.concat %w{search help reserved_routes}
        end
        user_route.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_url_handle edit_redirect_url edit_301 edit_exclude}
          edit.form_bottom.concat %w{edit_buttons}
          edit.right_side.concat %w{help reserved_routes}
        end
        user_route.new = user_route.edit
      end
    end

    def load_default_site_snippet_regions
      returning OpenStruct.new do |site_snippet|
        site_snippet.index = RegionSet.new do |index|
          index.top.concat %w{pagination_counts}
          index.before_list.concat %w{}
          index.list_headers.concat %w{name_column_header actions_column_header}
          index.list_data.concat %w{name_column actions_column}
          index.after_list.concat %w{pagination_links}
          index.action_row.concat %w{new_site_snippet}
          index.right_side.concat %w{search help}
        end
        site_snippet.show = RegionSet.new do |show|
          show.above_content.concat %w{action_list}
          show.tab_header.concat %w{general_tab_header}
          show.tabs.concat %w{general_tab}

          show.general_list_content.concat %w{show_data}
          show.general_data.concat %w{data_standard data_content_form}
          show.general_content_form_top.concat %w{}
          show.general_content_form.concat %w{content_form_editor}
          show.general_content_form_bottom.concat %w{content_form_buttons}

          show.below_content.concat %w{show_additional_script tab_javascript}
          show.right_side.concat %w{help}
        end
        site_snippet.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_name edit_content_type}
          edit.form_bottom.concat %w{edit_buttons}
          edit.right_side.concat %w{help}
        end
        site_snippet.live_content = RegionSet.new do |live_content|
          live_content.live_main.concat %w{edit_area_settings live_content}
        end
        site_snippet.new = site_snippet.edit
      end
    end

    def load_default_site_regions
      returning OpenStruct.new do |site|
        site.index = RegionSet.new do |index|
          index.top.concat %w{pagination_counts}
          index.before_list.concat %w{}
          index.list_headers.concat %w{name_column_header domain_column_header actions_column_header}
          index.list_data.concat %w{name_column domain_column actions_column}
          index.after_list.concat %w{pagination_links}
          index.action_row.concat %w{new_site_link}
          index.right_side.concat %w{}
        end
        site.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_name edit_domain}
          edit.form_bottom.concat %w{edit_buttons}
          edit.form_tabs.concat %w{tab_javascript tab_content}
          edit.tab_headers.concat %w{}
          edit.tabs.concat %w{}
          edit.right_side.concat %w{}
        end
        site.new = site.edit
        site.top_menu = RegionSet.new do |top_menu|
          top_menu.site_top_left_menu.concat %w{left_menu_form left_menu_links}
          top_menu.site_top_right_menu.concat %w{right_menu_extension_link right_menu_user_links}
        end
      end
    end

    def load_default_user_group_regions
      returning OpenStruct.new do |user_group|
        user_group.index = RegionSet.new do |index|
          index.top.concat %w{pagination_counts}
          index.before_list.concat %w{}
          index.list_headers.concat %w{name_column_header permissions_column_header actions_column_header}
          index.list_data.concat %w{name_column permissions_column actions_column}
          index.after_list.concat %w{pagination_links}
          index.action_row.concat %w{new_user_group}
          index.bottom.concat %w{}
          index.right_side.concat %w{}
        end
        user_group.edit = RegionSet.new do |edit|
          edit.main.concat %w{edit_form}
          edit.form_top.concat %w{edit_errors}
          edit.form.concat %w{edit_name edit_permissions}
          edit.form_bottom.concat %w{edit_buttons}
          edit.right_side.concat %w{}
        end
        user_group.new = user_group.edit
      end
    end

  end
end