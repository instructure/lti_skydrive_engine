require 'spec_helper'

module Skydrive
  describe ApiKeysController do
    routes { Skydrive::Engine.routes }

    describe "#oauth2_token" do
      it "should return 401 response with invalid code" do
        ApiKey.should_receive(:trade_oauth_code_for_access_token).
               with('INVALID_CODE').
               and_return(nil)

        post 'oauth2_token', code: 'INVALID_CODE'
        expect(response.status).to eq(400)
        json = JSON.parse(response.body)
        expect(json['message']).to eq("invalid code")
      end

      it "should return 201 response with valid code" do
        ApiKey.should_receive(:trade_oauth_code_for_access_token).
               with('VALID_CODE').
               and_return(1)

        post 'oauth2_token', code: 'VALID_CODE'
        expect(response.status).to eq(201)
        json = JSON.parse(response.body)
        expect(json['api_key']).to eq(1)
      end
    end

  end
end
