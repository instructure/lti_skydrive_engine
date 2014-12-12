module Skydrive
  class Account < ActiveRecord::Base
    validates :key, presence: true, uniqueness: true
    validates :secret, presence: true

    has_many :users

    def self.new_key
      Account.create(key: SecureRandom.uuid, secret: SecureRandom.hex)
    end
  end
end