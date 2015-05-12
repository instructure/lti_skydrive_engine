module Skydrive
  class User < ActiveRecord::Base
    include ActiveModel::ForbiddenAttributesProtection

    has_many :api_keys
    has_one :token
    belongs_to :account

    validates :username, presence: true
    validates :name, presence: true

    def session_api_key(params={})
      ApiKey.create(
        user_id: self.id,
        scope: 'session',
        init_params: params.to_json
      )
    end

    def cleanup_api_keys
      api_keys.inactive.each(&:destroy)
    end

    def valid_skydrive_token?
      !!self.token && self.token.is_valid?
    end

    def ensure_token
      self.token = self.create_token unless self.token
    end

    def reset_token!
      self.token.delete
      ensure_token
    end

    # Convenience method
    def onedrive_client
      @onedrive_client ||=
          Client.new(SHAREPOINT.merge(
                         personal_url: self.token.personal_url,
                         token: self.token.access_token
                     ))
    end
  end
end
