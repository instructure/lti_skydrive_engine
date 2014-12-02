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
  end
end
