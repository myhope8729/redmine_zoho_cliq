require 'net/http'

class ZohoCliq
  include Redmine::I18n

  def self.markup_format(text)
    # TODO: output format should be markdown, but at the moment there is no
    #       solution without using pandoc (http://pandoc.org/), which requires
    #       packages on os level
    #
    # Redmine::WikiFormatting.html_parser.to_text(text)
    ERB::Util.html_escape(text)
  end

  def self.default_url_options
    { only_path: true, script_name: Redmine::Utils.relative_url_root }
  end

  def self.speak_zoho(msg, url, options)
    headers = {
        'Content-Type' => 'application/json',
        'Authorization' => 'Zoho-authtoken ' + RedmineZohoCliq.settings[:zoho_authtoken]
    }
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(uri.path, headers)
    
    detail = []
    text = msg

    senderName = "Redmine"

    senderName = RedmineZohoCliq.settings[:zoho_username] if RedmineZohoCliq.settings[:zoho_username].present?

    if options[:attachment].present?
      if options[:attachment][:fields].present?
        options[:attachment][:fields].each {|x| detail << x[:title] + " : " + x[:value] }
      end
      text += "\r\n" + options[:attachment][:text] if options[:attachment][:text].present?
    end

    detailTitle = ""
    if detail != []
      detailTitle = "Detail"
    end
    
    content = {
      "text": text,
      "bot": {
        "name": senderName
      },
      "card": {
        "theme": "modern-inline"
      },
      "slides": [
        {
          "type": "list",
          "title": detailTitle ,
          "data": detail
        }
      ]
    }.to_json

    request.body = content
    response = http.request(request)
  end

  def self.zoho_message_url(proj)
    zoho_token = RedmineZohoCliq.settings[:zoho_authtoken]
    channel = RedmineZohoCliq.settings[:zoho_channel]
    pm = ZohoCliqSetting.find_by(project_id: proj.id)
    channel = pm.zoho_channel if !pm.nil? && pm.zoho_channel.present?
    return "https://cliq.zoho.com/api/v2/channelsbyname/" + channel + "/message"
  end

  def self.object_url(obj)
    if Setting.host_name.to_s =~ %r{\A(https?\://)?(.+?)(\:(\d+))?(/.+)?\z}i
      host = Regexp.last_match(2)
      port = Regexp.last_match(4)
      prefix = Regexp.last_match(5)
      Rails.application.routes.url_for(obj.event_url(host: host, protocol: Setting.protocol, port: port, script_name: prefix))
    else
      Rails.application.routes.url_for(obj.event_url(host: Setting.host_name, protocol: Setting.protocol, script_name: ''))
    end
  end

  def self.textfield_for_project(proj, config)
    return if proj.blank?

    # project based
    pm = ZohoCliqSetting.find_by(project_id: proj.id)
    return pm.send(config) if !pm.nil? && pm.send(config).present?

    default_textfield(proj, config)
  end

  def self.default_textfield(proj, config)
    # parent project based
    parent_field = textfield_for_project(proj.parent, config)
    return parent_field if parent_field.present?
    return RedmineZohoCliq.settings[config] if RedmineZohoCliq.settings[config].present?

    ''
  end

  def self.setting_for_project(proj, config)
    return false if proj.blank?

    @setting_found = 0
    # project based
    pm = ZohoCliqSetting.find_by(project_id: proj.id)
    unless pm.nil? || pm.send(config).zero?
      @setting_found = 1
      return false if pm.send(config) == 1
      return true if pm.send(config) == 2
      # 0 = use system based settings
    end
    default_project_setting(proj, config)
  end

  def self.default_project_setting(proj, config)
    if proj.present? && proj.parent.present?
      parent_setting = setting_for_project(proj.parent, config)
      return parent_setting if @setting_found == 1
    end
    # system based
    return true if RedmineZohoCliq.settings[config].present? && RedmineZohoCliq.setting?(config)

    false
  end

  def self.detail_to_field(detail)
    field_format = nil
    key = nil
    escape = true

    if detail.property == 'cf'
      key = CustomField.find(detail.prop_key).name rescue nil
      title = key
      field_format = CustomField.find(detail.prop_key).field_format rescue nil
    elsif detail.property == 'attachment'
      key = 'attachment'
      title = I18n.t :label_attachment
    else
      key = detail.prop_key.to_s.sub('_id', '')
      title = if key == 'parent'
                I18n.t "field_#{key}_issue"
              else
                I18n.t "field_#{key}"
              end
    end

    short = true
    value = detail.value.to_s

    case key
    when 'title', 'subject', 'description'
      short = false
    when 'tracker'
      tracker = Tracker.find(detail.value)
      value = tracker.to_s if tracker.present?
    when 'project'
      project = Project.find(detail.value)
      value = project.to_s if project.present?
    when 'status'
      status = IssueStatus.find(detail.value)
      value = status.to_s if status.present?
    when 'priority'
      priority = IssuePriority.find(detail.value)
      value = priority.to_s if priority.present?
    when 'category'
      category = IssueCategory.find(detail.value)
      value = category.to_s if category.present?
    when 'assigned_to'
      user = User.find(detail.value)
      value = user.to_s if user.present?
    when 'fixed_version'
      fixed_version = Version.find(detail.value)
      value = fixed_version.to_s if fixed_version.present?
    when 'attachment'
      attachment = Attachment.find(detail.prop_key)
      value = "<#{ZohoCliq.object_url attachment}|#{ERB::Util.html_escape(attachment.filename)}>" if attachment.present?
      escape = false
    when 'parent'
      issue = Issue.find(detail.value)
      value = "<#{ZohoCliq.object_url issue}|#{ERB::Util.html_escape(issue)}>" if issue.present?
      escape = false
    end

    if detail.property == 'cf' && field_format == 'version'
      version = Version.find(detail.value)
      value = version.to_s if version.present?
    end

    value = if value.present?
              if escape
                ERB::Util.html_escape(value)
              else
                value
              end
            else
              '-'
            end

    result = { title: title, value: value }
    result[:short] = true if short
    result
  end

  def self.extract_usernames(text)
    text = '' if text.nil?
    # ZohoCliq usernames may only contain lowercase letters, numbers,
    # dashes, dots and underscores and must start with a letter or number.
    text.scan(/@[a-z0-9][a-z0-9_\-.]*/).uniq
  end
end
