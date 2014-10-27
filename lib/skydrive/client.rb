require 'rest_client'
require 'curb'
require 'json'
require 'mimemagic'
require 'jwt'


module Skydrive
  class Client
    include ActionView::Helpers::NumberHelper

    attr_accessor :client_id, :client_secret, :guid, :client_domain, :token

    def initialize(options = {})
      options.each { |key, val| self.send("#{key}=", val) if self.respond_to?("#{key}=") }
    end

    # URL used to authorize this app for a sharepoint tenant
    def oauth_authorize_redirect_uri(redirect_uri, options = {})
      scope = options[:scope] || 'Web.Read AllSites.Write AllProfiles.Read'
      state = options[:state]
      redirect_params = {
          client_id: client_id,
          scope: scope,
          redirect_uri: redirect_uri,
          response_type: 'code'
      }
      "https://#{client_domain}/_layouts/15/OAuthAuthorize.aspx?" +
          redirect_params.map{|k,v| "#{k}=#{CGI::escape(v)}"}.join('&') +
          (state ? "&state=#{state}" : "")
    end

    # Service call for trading the OAuth 2 code for a token
    # This is used to authorize the app for a sharepoint tenant
    def authorize_app(redirect_uri, code)
      realm = self.get_realm
      endpoint = "https://accounts.accesscontrol.windows.net/#{realm}/tokens/OAuth/2"

      options = {
          content_type: 'application/x-www-form-urlencoded',
          client_id: "#{client_id}@#{realm}",
          redirect_uri: redirect_uri,
          client_secret: client_secret,
          code: code,
          grant_type: 'authorization_code',
          resource: "#{guid}/#{client_domain}@#{realm}",
      }

      RestClient.post endpoint, options do |response, request, result|
        log_restclient_response(response, request, result)
        results = format_results(JSON.parse(response))
        self.token = results['access_token']
        results
      end
    end

    # Service call for refreshing an admin oauth2 token
    def refresh_token(refresh_token)
      realm = self.get_realm
      endpoint = "https://accounts.accesscontrol.windows.net/#{realm}/tokens/OAuth/2"

      options = {
          content_type: 'application/x-www-form-urlencoded',
          client_id: "#{client_id}@#{realm}",
          client_secret: client_secret,
          refresh_token: refresh_token,
          grant_type: 'refresh_token',
          resource: "#{guid}/#{client_domain}@#{realm}",
      }

      RestClient.post endpoint, options do |response, request, result|
        log_restclient_response(response, request, result)
        results = format_results(JSON.parse(response))
        self.token = results['access_token']
        results
      end
    end

    # URL used to obtain an access token for a regular user
    def app_redirect_uri(redirect_uri, options = {})
      redirect_params = {
        client_id: client_id,
        redirect_uri: redirect_uri + "?state=#{options[:state]}",
      }

      "https://#{client_domain}/_layouts/15/appredirect.aspx?" +
        redirect_params.map{|k,v| "#{k}=#{CGI::escape(v)}"}.join('&')
    end

    # Service call for trading generating a token for a regular user
    def get_token(spAppToken)
      decoded = JWT.decode(spAppToken, SHAREPOINT[:client_secret], false).first
      acsServer = JSON.parse(decoded['appctx'])['SecurityTokenServiceUri']

      part1 = '00000003-0000-0ff1-ce00-000000000000'
      part2 =  client_domain
      part3 = decoded['appctxsender'].split('@')[1]

      postdata = {'grant_type' => 'refresh_token',
                  'client_id' => decoded['aud'],
                  'client_secret' => SHAREPOINT[:client_secret],
                  'refresh_token' => decoded['refreshtoken'],
                  'resource' => part1 + '/' + part2 + '@' + part3}

      result = RestClient.post acsServer, postdata do |response, request, result|
        log_restclient_response(response, request, result)
        result = JSON.parse(response)
        self.token = result['access_token']
        result
      end

      return result
    end

    def format_results(results)
      results["expires_in"] = results["expires_in"].to_i
      results["not_before"] = Time.at results["not_before"].to_i
      results["expires_on"] = Time.at results["expires_on"].to_i
      results
    end

    def get_realm
      #401 sharepoint challenge to get the realm
      resource = RestClient::Resource.new "https://#{client_domain}/_vti_bin/client.svc/",
                                          {headers: {'Authorization' => 'Bearer'}}
      www_authenticate = {}
      resource.get do |response, request, result|
        log_restclient_response(response, request, result)
        response.headers[:www_authenticate].scan(/[\w ]*="[^"]*"/).each do |attribute|
          attribute = attribute.split('=')
          www_authenticate[attribute.first] = attribute.last.delete('"')
        end
      end

      www_authenticate["Bearer realm"]
    end

    def get_folder_and_files(uri, folder = Skydrive::Folder.new)
      data = api_call(uri)

      folder.icon = "folder"
      folder.uri = uri
      folder.name = data['Name']
      folder.server_relative_url = data['ServerRelativeUrl']
      folder.parse_parent_uri
      folder.files = []
      folder.folders = []

      files = api_call(CGI::unescape(data['Files']['__deferred']['uri']))['results']
      files.each do |f|
        new_file = Skydrive::File.new
        new_file.uri = f['__metadata']['uri']
        new_file.file_size = number_to_human_size(f['Length'])
        new_file.name = f['Name']
        new_file.server_relative_url = f['ServerRelativeUrl']
        new_file.time_created = Date.parse(f['TimeCreated'])
        new_file.time_last_modified = Date.parse(f['TimeLastModified'])
        new_file.title = f['Title']
        new_file.content_tag = f['ContentTag']
        folder.files << new_file
      end
      
      sub_folders = api_call(CGI::unescape(data['Folders']['__deferred']['uri']))['results']
      sub_folders.each do |sf|

        # Non-recursively
        sub_folder = Skydrive::Folder.new
        sub_folder.parent_uri = uri
        sub_folder.icon = "folder"
        sub_folder.uri = sf['__metadata']['uri']
        sub_folder.name = sf['Name']
        sub_folder.server_relative_url = sf['ServerRelativeUrl']
        sub_folder.files = []
        sub_folder.folders = []

        #special exception for the special Forms folder in the root directory
        if !folder.parent_uri && sub_folder.name == 'Forms'
          next
        end

        # Recursively
        # sub_folder = get_folder_and_files(sf['__metadata']['uri'])

        folder.folders << sub_folder
      end

      return folder
    end

    def api_call(url)
      url.gsub!("https:/i", "https://i")
      uri = URI.escape(url)

      pid = generate_pid

      c = Curl::Easy.new(uri) do |http|
        http.headers['Authorization'] = "Bearer #{token}"
        http.headers['Accept'] = "application/json; odata=verbose"
      end

      headers = []
      buffer = ""
      c.on_body { |data| 
        buffer << data
        data.size
      }
      c.on_header { |data|
        headers << data
        data.size
      }
      c.perform

      Skydrive.logger.info("[#{pid}] SKYDRIVE REQUEST: #{uri.to_s}")
      headerOutput = c.headers.values.join("\n  - ")
      Skydrive.logger.info("[#{pid}] SKYDRIVE REQUEST HEADERS:\n  - #{headerOutput}")
      Skydrive.logger.info("[#{pid}] SKYDRIVE RESPONSE HEADERS:\n  - #{headers.join('  - ')}")
      Skydrive.logger.info("[#{pid}] SKYDRIVE RESPONSE BODY:\n#{buffer}");

      JSON.parse(buffer)["d"]
    end

    def get_user
      api_call("https://#{client_domain}/_api/SP.UserProfiles.PeopleManager/GetMyProperties")
    end

    private

    def log_restclient_response(response, request, result)
      pid = generate_pid
      Skydrive.logger.info("[#{pid}] SKYDRIVE REQUEST: #{request.url}")
      Skydrive.logger.info("[#{pid}] SKYDRIVE REQUEST PAYLOAD: #{request.payload}")
      headerOutput = request.headers.values.join("\n  - ")
      Skydrive.logger.info("[#{pid}] SKYDRIVE REQUEST HEADERS:\n  - #{headerOutput}")
      Skydrive.logger.info("[#{pid}] SKYDRIVE RESPONSE CODE: #{result.code}")
      Skydrive.logger.info("[#{pid}] SKYDRIVE RESPONSE BODY:\n#{response}")
    end

    def generate_pid
      (0...8).map { (65 + rand(26)).chr }.join
    end

  end
end
