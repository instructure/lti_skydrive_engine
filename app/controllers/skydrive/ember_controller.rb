require_dependency "skydrive/application_controller"

module Skydrive
  class EmberController < ApplicationController
    def index
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
