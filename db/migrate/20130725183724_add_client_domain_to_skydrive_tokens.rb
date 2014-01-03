class AddClientDomainToSkydriveTokens < ActiveRecord::Migration
  def change
    add_column :skydrive_tokens, :client_domain, :string
  end
end
