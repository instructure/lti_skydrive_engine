class ChangeSkydriveTokenLength < ActiveRecord::Migration[4.2]
  def change
    change_column :skydrive_tokens, :access_token, :text
    change_column :skydrive_tokens, :refresh_token, :text
  end
end
