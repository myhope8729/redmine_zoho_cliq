module RedmineZohoCliq
  module Patches
    module IssuePatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          after_create :send_messenger_create
          after_update :send_messenger_update
        end
      end

      module InstanceMethods
        def send_messenger_create
          url = ZohoCliq.zoho_message_url project

          #return unless channels.present? && url
          #return if is_private? && !Messenger.setting_for_project(project, :post_private_issues)

          set_language_if_valid Setting.default_language

          attachment = {}
          if description.present? && ZohoCliq.setting_for_project(project, :new_include_description)
            attachment[:text] = ZohoCliq.markup_format(description)
          end
          attachment[:fields] = [{ title: I18n.t(:field_status),
                                   value: ERB::Util.html_escape(status.to_s),
                                   short: true },
                                 { title: I18n.t(:field_priority),
                                   value: ERB::Util.html_escape(priority.to_s),
                                   short: true }]
          if assigned_to.present?
            attachment[:fields] << { title: I18n.t(:field_assigned_to),
                                     value: ERB::Util.html_escape(assigned_to.to_s),
                                     short: true }
          end

          if RedmineZohoCliq.setting?(:display_watchers) && watcher_users.count.positive?
            attachment[:fields] << {
              title: I18n.t(:field_watcher),
              value: ERB::Util.html_escape(watcher_users.join(', ')),
              short: true
            }
          end

          #send the created issue to zoho
          ZohoCliq.speak_zoho(l(:label_messager_issue_zoho_created,
                                project_url: "[#{ERB::Util.html_escape(project)}](#{ZohoCliq.object_url project})",
                                url: send_messenger_mention_zoho_url(project, description),
                                user: author), ZohoCliq.zoho_message_url(project), attachment: attachment, project: project)
        end

        def send_messenger_update
          return if current_journal.nil?

          url = ZohoCliq.zoho_message_url project

          return if current_journal.private_notes? && !ZohoCliq.setting_for_project(project, :post_private_notes)

          set_language_if_valid Setting.default_language

          attachment = {}
          if current_journal.notes.present? && ZohoCliq.setting_for_project(project, :updated_include_description)
            attachment[:text] = ZohoCliq.markup_format(current_journal.notes)
          end

          fields = current_journal.details.map { |d| ZohoCliq.detail_to_field d }
          if status_id != status_id_was
            fields << { title: I18n.t(:field_status),
                        value: ERB::Util.html_escape(status.to_s),
                        short: true }
          end
          if priority_id != priority_id_was
            fields << { title: I18n.t(:field_priority),
                        value: ERB::Util.html_escape(priority.to_s),
                        short: true }
          end
          if assigned_to.present?
            fields << { title: I18n.t(:field_assigned_to),
                        value: ERB::Util.html_escape(assigned_to.to_s),
                        short: true }
          end
          attachment[:fields] = fields if fields.any?

          #send the updated issue to zoho
          ZohoCliq.speak_zoho(l(:label_messenger_issue_zoho_updated,
                                project_url: "[#{ERB::Util.html_escape(project)}](#{ZohoCliq.object_url project})",
                                url: send_messenger_mention_zoho_url(project, current_journal.notes),
                                user: current_journal.user), ZohoCliq.zoho_message_url(project), attachment: attachment, project: project)
        end

        private

        def send_messenger_mention_zoho_url(project, text)
          mention_to = ''
          if ZohoCliq.setting_for_project(project, :auto_mentions) ||
             ZohoCliq.textfield_for_project(project, :default_mentions).present?
            mention_to = ZohoCliq.mentions(project, text)
          end
          "[#{ERB::Util.html_escape(self)}>#{mention_to}](#{ZohoCliq.object_url(self)})"
        end
      end
    end
  end
end
