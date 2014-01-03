module Skydrive
  class SkydriveToken < ActiveRecord::Base
    validates :user_id, uniqueness: true
    belongs_to :user

    def requires_refresh?
      !!self.not_before && self.not_before < Time.now
    end

    def is_valid?
      !!self.access_token && self.expires_on && self.expires_on > Time.now
    end
  end
end