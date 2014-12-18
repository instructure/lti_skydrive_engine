class AddPersonRequestInfoToAccounts < ActiveRecord::Migration
  def change
    add_column :skydrive_accounts, :name, :string
    add_column :skydrive_accounts, :email, :string
    add_column :skydrive_accounts, :institution, :string
    add_column :skydrive_accounts, :title, :string
  end
end
