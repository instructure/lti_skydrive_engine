class ChangeLtiKeysToAccount < ActiveRecord::Migration[4.2]
  def up
    rename_table :skydrive_lti_keys, :skydrive_accounts

    add_column :skydrive_accounts, :tool_consumer_instance_guid, :text
    add_column :skydrive_accounts, :admin_id, :integer
  end

  def down
    remove_column :skydrive_accounts, :tool_consumer_instance_guid, :text
    remove_column :skydrive_accounts, :admin_id, :integer

    rename_table :skydrive_accounts, :skydrive_lti_keys
  end
end
