# http://localhost:9393/download/file?access_token=516ad4d3-80b3-4da5-bb0f-b5651b9fce62&file=/personal/ericb_instructure_onmicrosoft_com/Documents/2013-05-17_1633.png

class SkydriveProxy
  def initialize(app)
    @app = app
  end

  def call(env)
    path = env["REQUEST_PATH"]
    if path =~ /^\/download\/.+/
      dup._call(env)
    else
      @status, @headers, @response = @app.call(env)
      [@status, @headers, self]
    end
  end

  def _call(env)
    params = Rack::Utils.parse_query(env["QUERY_STRING"])
    api_key = ApiKey.where(access_token: params['access_token']).first
    if api_key
      user = api_key.user
      uri = "#{user.token.personal_url}_api/Web/GetFileByServerRelativeUrl('#{params['file']}')"
      [200, {"Content-Type" => "text/plain"}, [uri]]
    else
      [401, {"Content-Type" => "text/plain"}, []]
    end
  end

  def each(&block)
    @response.each(&block)
  end
end