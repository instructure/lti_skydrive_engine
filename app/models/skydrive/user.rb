module Skydrive
  class User < ActiveRecord::Base
    include ActiveModel::ForbiddenAttributesProtection

    after_initialize :ensure_token
    after_initialize :cleanup_api_keys

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
      if self.token
        begin
          self.token.refresh! if self.token.requires_refresh?
        rescue Skydrive::APIResponseErrorException, JSON::ParserError => error
          self.reset_token!
        end
      end

      self.token = self.create_token unless self.token
    end

    def reset_token!
      self.token.delete
      ensure_token
    end

    def skydrive_client
      @skydrive_client ||=
          Client.new(SHAREPOINT.merge(
                          user_token: self.token
                     ))
    end
  end
end
