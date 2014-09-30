class AddAccountToUsers < ActiveRecord::Migration
  def up
    add_column :skydrive_users, :account_id, :integer
    add_column :skydrive_users, :lti_user_id, :text
  end

  def down
    remove_column :skydrive_users, :account_id, :integer
    remove_column :skydrive_users, :lti_user_id, :text
  end
end
