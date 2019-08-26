Rails.configuration.to_prepare do
  module RedmineZohoCliq
    REDMINE_CONTACTS_SUPPORT = Redmine::Plugin.installed?('redmine_contacts') ? true : false
    REDMINE_DB_SUPPORT = Redmine::Plugin.installed?('redmine_db') ? true : false
    # this does not work at the moment, because redmine loads passwords after messener plugin
    REDMINE_PASSWORDS_SUPPORT = Redmine::Plugin.installed?('redmine_passwords') ? true : false

    def self.settings
      if Setting[:plugin_redmine_zoho_cliq].class == Hash
        if Rails.version >= '5.2'
          # convert Rails 4 data
          new_settings = ActiveSupport::HashWithIndifferentAccess.new(Setting[:plugin_redmine_zoho_cliq])
          Setting.plugin_redmine_zoho_cliq = new_settings
          new_settings
        else
          ActionController::Parameters.new(Setting[:plugin_redmine_zoho_cliq])
        end
      else
        # Rails 5 uses ActiveSupport::HashWithIndifferentAccess
        Setting[:plugin_redmine_zoho_cliq]
      end
    end

    def self.setting?(value)
      return true if settings[value].to_i == 1
      false
    end

  end

  # Patches
  Issue.send(:include, RedmineZohoCliq::Patches::IssuePatch)
  WikiPage.send(:include, RedmineZohoCliq::Patches::WikiPagePatch)
  ProjectsController.send :helper, ZohoCliqProjectsHelper
  Contact.send(:include, RedmineZohoCliq::Patches::ContactPatch) if RedmineZohoCliq::REDMINE_CONTACTS_SUPPORT
  DbEntry.send(:include, RedmineZohoCliq::Patches::DbEntryPatch) if RedmineZohoCliq::REDMINE_DB_SUPPORT
  Password.send(:include, RedmineZohoCliq::Patches::PasswordPatch) if Redmine::Plugin.installed?('redmine_passwords')

  # Global helpers
  ActionView::Base.send :include, RedmineZohoCliq::Helpers

  # Hooks
  require_dependency 'redmine_zoho_cliq/hooks'

end
