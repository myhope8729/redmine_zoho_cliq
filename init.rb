raise "\n\033[31mredmine_zoho_cliq requires ruby 2.3 or newer. Please update your ruby version.\033[0m" if RUBY_VERSION < '2.3'

require 'redmine'
require 'redmine_zoho_cliq'

Redmine::Plugin.register :redmine_zoho_cliq do
  name 'Redmine Zoho Cliq'
  author 'Andres'
  url ''
  author_url ''
  description 'Messenger integration for Zoho Cliq support'
  version '1.0.0'

  requires_redmine version_or_higher: '3.0.0'

  permission :manage_zoho_cliq, projects: :settings, zoho_cliq_settings: :update

  settings default: {
    zoho_authtoken: '',
    zoho_channel:'',
    zoho_username:'',
    display_watchers: '0',
    post_updates: '1',
    new_include_description: '1',
    updated_include_description: '1',
    post_private_contacts: '0',
    post_private_db: '0',
    post_private_issues: '0',
    post_private_notes: '0',
    post_wiki: '0',
    post_wiki_updates: '0',
    post_db: '0',
    post_db_updates: '0',
    post_contact: '0',
    post_contact_updates: '0',
    post_password: '0',
    post_password_updates: '0'
  }, partial: 'settings/zoho_cliq_settings'
end
