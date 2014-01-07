module Skydrive
  class ApplicationController < ActionController::Base
    protected

    # Renders a 401 status code if the current user is not authorized
    def ensure_authenticated_user
      head :unauthorized unless current_user
    end

    # Returns the active user associated with the access token if available
    def current_user
      return @current_user if @current_user
      if current_api_key
        return @current_user = current_api_key.user
      else
        return nil
      end
    end

    # Parses the access token from the header
    def current_api_key
      return @current_api_key if @current_api_key.present?

      bearer = request.headers["HTTP_AUTHORIZATION"]

      bearer ||= params[:access_token]

      # allows our tests to pass
      bearer ||= request.headers["rack.session"].try(:[], 'Authorization')

      if bearer.present?
        token = bearer.split.last
        @current_api_key = ApiKey.where(access_token: token).first
      else
        nil
      end
      @current_api_key
    end

end
