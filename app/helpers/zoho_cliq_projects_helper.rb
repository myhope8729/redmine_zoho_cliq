module ZohoCliqProjectsHelper
  def project_settings_tabs
    tabs = super

    if User.current.allowed_to?(:manage_zoho_cliq, @project)
      tabs << { name: 'zoho_cliq',
                action: :show,
                partial: 'zoho_cliq_settings/show',
                label: :label_zohocliq }
    end

    tabs
  end
end
