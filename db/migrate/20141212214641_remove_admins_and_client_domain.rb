class RemoveAdminsAndClientDomain < ActiveRecord::Migration[4.2]
  def up
    remove_column :skydrive_tokens, :client_domain
    remove_column :skydrive_accounts, :admin_id
    Skydrive::User.delete_all
  end

  def down
    add_column :skydrive_tokens, :client_domain, :string
    add_column :skydrive_accounts, :admin_id, :integer
  end
end
