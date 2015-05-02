require 'raven'
require 'ims/lti'

module Skydrive

  ERROR_NO_API_KEY = "Unable to get an access token, your state is invalid"
  ERROR_JSON_PARSE = "JSON::ParserError"
  ERROR_SKY_DRIVE_API = "Skydrive::APIErrorException"



  class LaunchController < ApplicationController
    include ActionController::Cookies
    before_filter :ensure_authenticated_user, only: :skydrive_authorized

    def tool_provider
      require 'oauth/request_proxy/rack_request'

      @account = Account.where(key: params['oauth_consumer_key']).first

      if @account
        key = @account.key
        secret = @account.secret
      end

      tp = IMS::LTI::ToolProvider.new(key, secret, params)

      if !key
        tp.lti_errorlog = "Invalid consumer key or secret"
      elsif !secret
        tp.lti_errorlog = "Consumer key wasn't recognized"
      elsif !tp.valid_request?(request)
        tp.lti_errorlog = "The OAuth signature was invalid"
      elsif Time.now.utc.to_i - tp.request_oauth_timestamp.to_i > 120
        tp.lti_errorlog = "Your request is too old"
      end

      #
      ## this isn't actually checking anything like it should, just want people
      ## implementing real tools to be aware they need to check the nonce
      #if was_nonce_used_in_last_x_minutes?(@tp.request_oauth_nonce, 60)
      #  register_error "Why are you reusing the nonce?"
      #  return false
      #end

      return tp
    end

    def basic_launch

      tp = tool_provider
      if tp.lti_errorlog
        render text: tp.lti_errorlog, status: 400, layout: "skydrive/error"
        return
      end

      user = @account.users.where(username: tp.user_id).first ||
          @account.users.create(
              lti_user_id: tp.user_id,
              name: tp.lis_person_name_full,
              username: tp.user_id,
              email: tp.lis_person_contact_email_primary,
          )

      user.ensure_token
      user.cleanup_api_keys

      code = user.session_api_key(params).oauth_code
      redirect_to "#{root_path}launch/#{code}"
    end

    def skydrive_authorized
      skydrive_token = current_user.token
      if skydrive_token && skydrive_token.requires_refresh?
        begin
          skydrive_client.refresh_token = skydrive_token.refresh_token
          skydrive_token.refresh!(skydrive_client)
        rescue Skydrive::APIResponseErrorException => error
          current_user.reset_token!
        end
      end

      if skydrive_token && skydrive_token.is_valid?
        render json: {}, status: 201
      else
        code = current_user.api_keys.active.skydrive_oauth.create.oauth_code
        render text: skydrive_client.oauth_authorize_redirect_uri(microsoft_oauth_url, state: code), status: 401
      end
    end

    def microsoft_oauth
      begin
        api_key = ApiKey.trade_oauth_code_for_access_token(params['state'])
        raise RuntimeError, ERROR_NO_API_KEY unless api_key

        @current_user = api_key.user
        skydrive_client.request_oauth_token(params['code'], microsoft_oauth_url)
        service = skydrive_client.get_my_files_service()
        current_user.token.resource = service["serviceResourceId"]
        current_user.token.refresh!(skydrive_client)

        personal_url = skydrive_client.get_personal_url(service["serviceEndpointUri"]).gsub(/\/Documents$/,'/')
        current_user.token.update_attribute(:personal_url, personal_url)

        redirect_to "#{root_path}oauth/callback"
      rescue Exception => api_error
        launch_exception_handler api_error
      end
    end

    def xml_config
      host = request.scheme + "://" + request.host_with_port + "/"

      url = "#{request.protocol}#{request.host_with_port}#{launch_path}"
      title = "Onedrive Pro"
      tc = IMS::LTI::ToolConfig.new(:title => title, :launch_url => url)
      tc.extend IMS::LTI::Extensions::Canvas::ToolConfig
      tc.description = 'Allows you to pull in documents from Onedrive Pro to canvas'
      tc.canvas_privacy_public!
      tc.canvas_domain!(request.host)
      tc.canvas_icon_url!("#{host}assets/skydrive/skydrive_icon.png")
      tc.canvas_selector_dimensions!(700,600)
      tc.canvas_text!(title)
      tc.canvas_homework_submission!
      tc.canvas_account_navigation!
      tc.canvas_course_navigation!(visibility: 'admin')
      render xml: tc.to_xml
    end

    def skydrive_logout
      render json: {}, status: 200
      current_user.token.destroy
    end

    def launch_error
      @title = %s{Ooops! Something went terribly wrong!}
      @message = %s{Not sure what happened, or how you got here?!}
      render status: 400, layout: "skydrive/error"
    end

    private
    def launch_exception_handler(api_error)
      RavenLogger.capture_exception(api_error)
      @api_error = api_error
      @title = %s{Ooops! Something went terribly wrong!}
      @message = ""

      if api_error.message == ERROR_SKY_DRIVE_API
        @message = %s{The OneDrive API returned an error. Close any popups, and relaunch OneDrive.}
      elsif api_error.message == ERROR_JSON_PARSE
        @message = %s{The OneDrive API returned an invalid response. Close any popups, and relaunch OneDrive.}
      elsif api_error.message == ERROR_NO_API_KEY
        @title = %s{Unable to retrieve an access token}
        @message = %s{It looks like your using an old page. Close any popups, and relaunch OneDrive.}
      end

      render action: :launch_error, status: 400, layout: "skydrive/error"
    end
  end
end
