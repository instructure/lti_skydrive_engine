require_dependency "skydrive/application_controller"

module Skydrive
  class EmberController < ApplicationController
    def index
      @full_path = request.env['SCRIPT_NAME']
      @env = {
        'CONFIG' => {
          host: @full_path
        }
      }
      render layout: false
    end

    def health_check
      begin
        ApiKey.count
        head 200
      rescue
        head 500
      end
    end
  end
end
