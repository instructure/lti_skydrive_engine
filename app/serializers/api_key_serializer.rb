require 'active_model/serializer'

module Skydrive
  class ApiKeySerializer < ActiveModel::Serializer
    attributes :id, :user_id, :access_token
  end
end
