require 'spec_helper'

module Skydrive
  describe ApiKey do
    let(:user) {User.create(:email => 'email@email.com', username: 'user', name: 'User')}
    it "creates api keys" do
      api_key = ApiKey.create(scope: 'session', user: user)
      expect(api_key).to_not be_new_record
      expect(api_key.expired_at).to be_a Time
      expect(api_key.oauth_code).to_not be_empty
    end

    it "trade a code for a token" do
      api_key = ApiKey.create(scope: 'session', user: user)
      expect(ApiKey.trade_oauth_code_for_access_token(api_key.oauth_code)).to eq(api_key)
      api_key.reload
      expect(api_key.oauth_code).to  be_nil
      expect(api_key.access_token).to_not be_empty
    end
  end
end
