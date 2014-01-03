module Skydrive
  class LtiKey < ActiveRecord::Base
    validates :key, presence: true, uniqueness: true
    validates :secret, presence: true

    def self.new_key
      LtiKey.create(key: SecureRandom.uuid, secret: SecureRandom.hex)
    end
  end
end