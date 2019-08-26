module RedmineZohoCliq
  module Patches
    module WikiPagePatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_create :send_messenger_create
          after_update :send_messenger_update
        end
      end

      module InstanceMethods
        def send_messenger_create
          return unless ZohoCliq.setting_for_project(project, :post_wiki)

          set_language_if_valid Setting.default_language

          url = ZohoCliq.zoho_message_url project

          #return unless channels.present? && url

          ZohoCliq.speak_zoho(l(:label_messenger_wiki_zoho_created,
                            project_url: "[#{ERB::Util.html_escape(project)}](#{ZohoCliq.object_url project})",
                            url: "[#{title}](#{ZohoCliq.object_url self})",
                            user: User.current),
                          ZohoCliq.zoho_message_url(project), project: project)
        end

        def send_messenger_update
          return unless ZohoCliq.setting_for_project(project, :post_wiki_updates)

          set_language_if_valid Setting.default_language

          url = ZohoCliq.zoho_message_url project

          #return unless channels.present? && url

          attachment = nil
          if !content.nil? && content.comments.present?
            attachment = {}
            attachment[:text] = ZohoCliq.markup_format(content.comments.to_s)
          end

          ZohoCliq.speak_zoho(l(:label_messenger_wiki_zoho_updated,
                            project_url: "[#{ERB::Util.html_escape(project)}](#{ZohoCliq.object_url project})",
                            url: "[#{title}](#{ZohoCliq.object_url self})",
                            user: content.author),
                           ZohoCliq.zoho_message_url(project), project: project, attachment: attachment)
        end
      end
    end
  end
end
