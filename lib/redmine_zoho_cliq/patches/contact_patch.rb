module RedmineZohoCliq
  module Patches
    module ContactPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_create :send_messenger_create
          after_update :send_messenger_update
        end
      end

      module InstanceMethods
        def send_messenger_create
          return unless ZohoCliq.setting_for_project(project, :post_contact)
          return if is_private? && !ZohoCliq.setting_for_project(project, :post_private_contacts)

          set_language_if_valid Setting.default_language

          url = ZohoCliq.zoho_message_url project

          #return unless channels.present? && url

          ZohoCliq.speak_zoho(l(:label_messenger_contact_created,
                            project_url: "[#{ERB::Util.html_escape(project)}](#{ZohoCliq.object_url project})",
                            url: "[#{name}](#{ZohoCliq.object_url self})",
                            user: User.current),
                          url, project: project)
        end

        def send_messenger_update
          return unless ZohoCliq.setting_for_project(project, :post_contact_updates)
          return if is_private? && !ZohoCliq.setting_for_project(project, :post_private_contacts)

          set_language_if_valid Setting.default_language

          url = ZohoCliq.zoho_message_url project

          #return unless channels.present? && url

          ZohoCliq.speak_zoho(l(:label_messenger_contact_zoho_updated,
                            project_url: "[#{ERB::Util.html_escape(project)}](#{ZohoCliq.object_url project})",
                            url: "[#{name}](#{ZohoCliq.object_url self})",
                            user: User.current),
                          url, project: project)
        end
      end
    end
  end
end
