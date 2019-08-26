require File.expand_path('../../test_helper', __FILE__)

class RoutingTest < Redmine::RoutingTest
  test 'routing zoho_cliq' do
    should_route 'GET /projects/1/settings/zoho_cliq' => 'projects#settings', id: '1', tab: 'zoho_cliq'
    should_route 'PUT /projects/1/zoho_cliq_setting' => 'zoho_cliq_settings#update', project_id: '1'
  end
end
