class AddClientDomainToSkydriveTokens < ActiveRecord::Migration[4.2]
  def change
    add_column :skydrive_tokens, :client_domain, :string
  end
end
