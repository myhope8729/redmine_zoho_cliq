module RedmineZohoCliq
  module Patches
    module DbEntryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_create :send_messenger_create
          after_update :send_messenger_update
        end
      end

      module InstanceMethods
        def send_messenger_create
          return unless ZohoCliq.setting_for_project(project, :post_db)
          return if is_private? && !ZohoCliq.setting_for_project(project, :post_private_db)

          set_language_if_valid Setting.default_language

          url = ZohoCliq.zoho_message_url project

          #return unless channels.present? && url

          ZohoCliq.speak_zoho(l(:label_messenger_db_entry_zoho_created,
                            project_url: "[#{ERB::Util.html_escape(project)}](#{ZohoCliq.object_url project})",
                            url: "[#{name}](#{ZohoCliq.object_url self})",
                            user: User.current),
                          url, project: project)
        end

        def send_messenger_update
          return unless ZohoCliq.setting_for_project(project, :post_db_updates)
          return if is_private? && !ZohoCliq.setting_for_project(project, :post_private_db)

          set_language_if_valid Setting.default_language

          url = ZohoCliq.zoho_message_url project

          #return unless channels.present? && url

          ZohoCliq.speak_zoho(l(:label_messenger_db_entry_zoho_updated,
                            project_url: "[#{ERB::Util.html_escape(project)}](#{ZohoCliq.object_url project})",
                            url: "[#{name}](#{ZohoCliq.object_url self})",
                            user: User.current),
                          url, project: project)
        end
      end
    end
  end
end
