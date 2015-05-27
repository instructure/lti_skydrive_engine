require 'spec_helper'

module Skydrive
  describe User do
    it "creates token if one doesnt exist" do
      user = User.create(:email => 'email@email.com', username: 'user', name: 'User')
      expect(user.token).to be_a(Token)
    end
  end
end
