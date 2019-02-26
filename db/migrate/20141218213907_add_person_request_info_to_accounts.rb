class AddPersonRequestInfoToAccounts < ActiveRecord::Migration[4.2]
  def change
    add_column :skydrive_accounts, :name, :string
    add_column :skydrive_accounts, :email, :string
    add_column :skydrive_accounts, :institution, :string
    add_column :skydrive_accounts, :title, :string
  end
end
