class SkydriveNamespace < ActiveRecord::Migration
  def self.up
    rename_table :api_keys, :skydrive_api_keys
    rename_table :lti_keys, :skydrive_lti_keys
    rename_table :users, :skydrive_users
  end

  def self.down
    rename_table :skydrive_api_keys, :api_keys
    rename_table :skydrive_lti_keys, :lti_keys
    rename_table :skydrive_users, :users
  end
end
