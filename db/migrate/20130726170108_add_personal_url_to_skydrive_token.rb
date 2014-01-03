class AddPersonalUrlToSkydriveToken < ActiveRecord::Migration
  def change
    add_column :skydrive_tokens, :personal_url, :string
  end
end
