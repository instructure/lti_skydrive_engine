module Skydrive
  class Token < ActiveRecord::Base
    USER = 'user'
    ADMIN = 'admin'

    validates :user_id, uniqueness: true
    belongs_to :user

    def requires_refresh?
      !!self.not_before && self.not_before < Time.now
    end

    def is_valid?
      !!self.access_token && self.expires_on && self.expires_on > Time.now
    end

    def refresh!(client)
      results = {}
      case token_type
        when USER
          results = client.get_token(refresh_token)
          self.personal_url ||= client.get_user['PersonalUrl']
        when ADMIN
          results = client.refresh_token(refresh_token)
      end

      if results.key? 'access_token'
        self.access_token = results['access_token']
        self.not_before = Time.at(results['not_before'].to_i)
        self.expires_on = Time.at(results['expires_on'].to_i)
        self.expires_in = results['expires_in']
        save
      end
    end
  end
end