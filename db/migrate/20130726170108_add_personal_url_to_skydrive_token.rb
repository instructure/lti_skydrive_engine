class AddPersonalUrlToSkydriveToken < ActiveRecord::Migration[4.2]
  def change
    add_column :skydrive_tokens, :personal_url, :string
  end
end
