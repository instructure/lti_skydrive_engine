require 'active_model/serializer'

module Skydrive
  class UserSerializer < ActiveModel::Serializer
    attributes :id, :name, :username, :email
  end
end
