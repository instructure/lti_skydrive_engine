module Skydrive
  class ApiKeysController < ApplicationController
    def oauth2_token
      api_key = ApiKey.trade_oauth_code_for_access_token(params['code'])
      if api_key
        render json: { api_key: api_key }, status: 201
      else
        render json: {"message" => "invalid code"}, status: 400
      end
    end
  end
end
