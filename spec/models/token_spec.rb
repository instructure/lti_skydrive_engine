require 'spec_helper'

module Skydrive
  describe Token do
    let(:user) {User.create(:email => 'email@email.com', username: 'user', name: 'User')}
    it "requires_refresh? shouldn't be true when empty" do
      token = Token.create(user: user)
      expect(token.requires_refresh?).to be(false)
    end
  end
end
