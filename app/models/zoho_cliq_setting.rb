class ZohoCliqSetting < ActiveRecord::Base
  belongs_to :project

  def self.find_or_create(p_id)
    setting = ZohoCliqSetting.find_by(project_id: p_id)
    unless setting
      setting = ZohoCliqSetting.new
      setting.project_id = p_id
      setting.save!
    end

    setting
  end
end
