module RedmineZohoCliq
  class ZohoCliqListener < Redmine::Hook::Listener
    def model_changeset_scan_commit_for_issue_ids_pre_issue_update(context = {})
      issue = context[:issue]
      journal = issue.current_journal
      changeset = context[:changeset]

      return unless issue.changes.any? && ZohoCliq.setting_for_project(issue.project, :post_updates)
      return if issue.is_private? && !ZohoCliq.setting_for_project(issue.project, :post_private_issues)

      msg = "[#{ERB::Util.html_escape(issue.project)}] #{ERB::Util.html_escape(journal.user.to_s)} updated <#{ZohoCliq.object_url issue}|#{ERB::Util.html_escape(issue)}>"

      repository = changeset.repository

      if Setting.host_name.to_s =~ %r{/\A(https?\:\/\/)?(.+?)(\:(\d+))?(\/.+)?\z/i}
        host = Regexp.last_match(2)
        port = Regexp.last_match(4)
        prefix = Regexp.last_match(5)
        revision_url = Rails.application.routes.url_for(
          controller: 'repositories',
          action: 'revision',
          id: repository.project,
          repository_id: repository.identifier_param,
          rev: changeset.revision,
          host: host,
          protocol: Setting.protocol,
          port: port,
          script_name: prefix
        )
      else
        revision_url = Rails.application.routes.url_for(
          controller: 'repositories',
          action: 'revision',
          id: repository.project,
          repository_id: repository.identifier_param,
          rev: changeset.revision,
          host: Setting.host_name,
          protocol: Setting.protocol
        )
      end

      attachment = {}
      attachment[:text] = ll(Setting.default_language, :text_status_changed_by_changeset, "<#{revision_url}|#{ERB::Util.html_escape(changeset.comments)}>")
      attachment[:fields] = journal.details.map { |d| ZohoCliq.detail_to_field d }

      ZohoCliq.speak_zoho(msg, ZohoCliq.zoho_message_url(repository.project), attachment: attachment, project: repository.project)
    end
  end
end
