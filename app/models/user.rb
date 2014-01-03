module Skydrive
  class User < ActiveRecord::Base
    include ActiveModel::ForbiddenAttributesProtection

    has_many :api_keys
    has_one :skydrive_token

    validates :email, presence: true, uniqueness: true
    validates :username, presence: true, uniqueness: true
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
      self.skydrive_token && self.skydrive_token.is_valid?
    end
  end
end