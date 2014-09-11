module Skydrive
  class Account < ActiveRecord::Base
    validates :key, presence: true, uniqueness: true
    validates :secret, presence: true

    belongs_to :admin, class_name: "User"
    has_many :users

    def self.new_key
      Account.create(key: SecureRandom.uuid, secret: SecureRandom.hex)
    end
  end
end