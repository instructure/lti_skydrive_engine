module Skydrive
  class ApiKey < ActiveRecord::Base
    validates :scope, inclusion: { in: %w( session api skydrive_oauth) }
    #before_create :generate_access_token, :set_expiry_date
    before_create :generate_code, :set_expiry_date
    belongs_to :user

    scope :session,       -> { where(scope: 'session') }
    scope :skydrive_oauth,-> { where(scope: 'skydrive_oauth') }
    scope :api,           -> { where(scope: 'api') }
    scope :active,        -> { where("expired_at >= ?", Time.now) }
    scope :inactive,      -> { where("expired_at < ?", Time.now) }

    def params
      self.init_params ? JSON.parse(self.init_params) : {}
    end

    private

    def set_expiry_date
      self.expired_at = case self.scope
                          when 'session'
                            60.minutes.from_now
                          when 'skydrive_oauth'
                            30.minutes.from_now
                          else
                            #Unsupported token types will start expired
                            Time.now
                        end
    end

    def generate_code
      self.oauth_code = SecureRandom.uuid
    end

    def self.trade_oauth_code_for_access_token(oauth_code)
      api_key = ApiKey.active.where(oauth_code: oauth_code).first if oauth_code
      api_key.update(access_token: SecureRandom.uuid, oauth_code: nil) if api_key
      api_key
    end
  end
end
