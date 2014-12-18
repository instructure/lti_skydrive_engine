require_dependency "skydrive/application_controller"

module Skydrive
  class EmberController < ApplicationController
    def index
    end

    def new_authentication
      @account = Account.new
      render layout: false
    end

    def generate_authentication
      @account = Account.new(account_params)
      @account.key = SecureRandom.uuid
      @account.secret = SecureRandom.hex
      if !@account.save
        render 'new_authentication', layout: false
      end
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

    private

    def account_params
      params.require(:account).permit(:name, :email, :institution, :title)
    end
  end
end
