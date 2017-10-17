class AddIndexToLtiSkydrive < ActiveRecord::Migration
  def change
    add_index(:skydrive_api_keys, :scope)
    add_index(:skydrive_api_keys, :expired_at)

    add_index(:skydrive_users, :account_id)
    add_index(:skydrive_users, :username)
    add_index(:skydrive_users, :email)
  end
end
