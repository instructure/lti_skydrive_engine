require 'rest_client'
require 'curb'
require 'json'
require 'mimemagic'
require 'jwt'
require 'skydrive/raven_logger'


module Skydrive
  class APIErrorException < RuntimeError
  end

  class APIResponseErrorException < RuntimeError
    attr_reader :response, :code, :description
    def initialize(response)
      @response = response
      @code = response['error']
      @description = response['error_description']
      super("#{@code}: #{@description}\n#{response}")
    end
  end

  class Client
    include ActionView::Helpers::NumberHelper

    attr_accessor :client_id, :client_secret, :guid, :personal_url, :token, :refresh_token

    def initialize(options = {})
      options.each do |key, val|
        self.send("#{key}=", val) if self.respond_to?("#{key}=")
      end
    end

    # URL used to authorize this app for a sharepoint tenant
    def oauth_authorize_redirect_uri(redirect_uri, options = {})
      state = options[:state]
      redirect_params = {
          client_id: client_id,
          redirect_uri: redirect_uri,
          response_type: 'code',
          resource: 'https://api.office.com/discovery/'
      }
      "https://login.windows.net/common/oauth2/authorize?" +
          redirect_params.map{|k,v| "#{k}=#{CGI::escape(v)}"}.join('&') +
          (state ? "&state=#{state}" : "")
    end

    def request_oauth_token(code, redirect_url)
      endpoint = 'https://login.windows.net/common/oauth2/token'
      options = {
          client_id: client_id,
          client_secret: client_secret,
          code: code,
          redirect_uri: redirect_url,
          resource: 'https://api.office.com/discovery/',
          grant_type: 'authorization_code',
      }

      RestClient.post endpoint, options do |response, request, result|
        log_restclient_response(response, request, result)
        results = format_results(parse_api_response(response))
        self.token = results['access_token']
        self.refresh_token = results['refresh_token']
        results
      end
    end

    def get_my_files_service
      services = api_call('https://api.office.com/discovery/v1.0/me/services', {'Accept' => nil})
      services["value"].find{|v| v["capability"] = "MyFiles"}
    end

    def get_personal_url(service_endpoint_uri)
      self.personal_url = api_call("#{service_endpoint_uri}/files/root/weburl", {'Accept' => nil})['value']
    end

    def refresh_token(params)
      endpoint = 'https://login.windows.net/common/oauth2/token'
      options = {
          client_id: client_id,
          client_secret: client_secret,
          grant_type: 'refresh_token',
          refresh_token: @refresh_token
      }.merge(params)

      RestClient.post endpoint, options do |response, request, result|
        log_restclient_response(response, request, result)
        results = format_results(parse_api_response(response))
        self.token = results['access_token']
        self.refresh_token = results['refresh_token']
        results
      end
    end

    def format_results(results)
      results["expires_in"] = results["expires_in"].to_i
      results["not_before"] = Time.at results["not_before"].to_i
      results["expires_on"] = Time.at results["expires_on"].to_i
      results
    end

    def get_realm
      #401 sharepoint challenge to get the realm
      resource = RestClient::Resource.new "#{personal_url}/_vti_bin/client.svc/",
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

    def api_call(url, headers = {})
      begin

        url.gsub!("https:/i", "https://i")
        uri = URI.escape(url)


        headers['Authorization'] = "Bearer #{token}" unless headers.has_key? 'Authorization'
        headers['Accept'] = "application/json; odata=verbose" unless headers.has_key? 'Accept'

        c = Curl::Easy.new(uri) do |http|
          headers.each {|k,v| http.headers[k] = v if v }
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

        result = parse_api_response(buffer)
      rescue Exception => error
        pid = generate_pid
        headerOutput = c.headers.map {|k,v| "#{k}: #{v}"}.join("\n[#{pid}] - ")
        backtrace_output = error.backtrace.join("\n[#{pid}] - ")
        buffer_output = buffer.split("\n").join("\n[#{pid}] - ")

        Skydrive.logger.error("[#{pid}] SKYDRIVE ERROR: #{error.class.to_s} ◊ #{error}")
        Skydrive.logger.info("[#{pid}] SKYDRIVE BACKTRACE: \n[#{pid}] - #{backtrace_output}")
        Skydrive.logger.info("[#{pid}] SKYDRIVE REQUEST: #{uri.to_s}")
        Skydrive.logger.info("[#{pid}] SKYDRIVE REQUEST HEADERS:\n[#{pid}] - #{headerOutput}")
        Skydrive.logger.info("[#{pid}] SKYDRIVE RESPONSE HEADERS:\n[#{pid}] - #{headers.join('  - ')}")
        Skydrive.logger.info("[#{pid}] SKYDRIVE RESPONSE BODY:\n[#{pid}] - #{buffer_output}");
        Skydrive.logger.info("[#{pid}] END --\n");
        RavenLogger.capture_exception(error)
        if error.instance_of(APIResponseErrorException)
          raise error
        end
        raise APIErrorException, error.class.to_s
      end

      result["d"] || result
    end

    def get_user
      api_call("#{personal_url}/_api/SP.UserProfiles.PeopleManager/GetMyProperties")
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

    def parse_api_response(body)
      result = JSON.parse(body)
      raise APIResponseErrorException, result if result["error"]
      result
    end
  end
end
