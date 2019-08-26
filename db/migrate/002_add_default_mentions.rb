class AddDefaultMentions < Rails.version < '5.2' ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
  def change
    add_column :zoho_cliq_settings, :default_mentions, :string
  end
end
