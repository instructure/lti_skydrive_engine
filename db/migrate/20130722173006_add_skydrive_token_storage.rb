class AddSkydriveTokenStorage < ActiveRecord::Migration[4.2]
  def change
    create_table :skydrive_tokens do |t|
      t.integer :user_id
      t.string :token_type
      t.string :access_token
      t.integer :expires_in
      t.string :refresh_token
      t.datetime :not_before
      t.datetime :expires_on
      t.string :resource
    end
    add_index :skydrive_tokens, :user_id
  end
end
