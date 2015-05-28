module Skydrive
  class Token < ActiveRecord::Base
    validates :user_id, uniqueness: true
    belongs_to :user

    def requires_refresh?
      !!(self.not_before && !self.not_before.is_a?(Time) && self.not_before < Time.now)
    end

    def is_valid?
      !!self.access_token && self.expires_on && self.expires_on > Time.now
    end

    def refresh!
      results = {}
      results = self.user.skydrive_client.update_api_tokens(resource: resource, refresh_token: refresh_token, token: access_token)
      if results.key? 'access_token'
        attrs = ['token_type', 'expires_in', 'expires_on', 'not_before', 'resource', 'access_token', 'refresh_token']
        update_attributes(results.reject{|a| !attrs.include?(a)})
      end
    end
  end
end
