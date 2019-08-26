module RedmineZohoCliq
  module Helpers
    def project_zoho_cliq_options(active)
      options_for_select({ l(:label_messenger_settings_default) => '0',
                           l(:label_messenger_settings_disabled) => '1',
                           l(:label_messenger_settings_enabled) => '2' }, active)
    end

    def project_setting_zoho_cliq_default_value(value)
      if ZohoCliq.default_project_setting(@project, value)
        l(:label_messenger_settings_enabled)
      else
        l(:label_messenger_settings_disabled)
      end
    end
  end
end
