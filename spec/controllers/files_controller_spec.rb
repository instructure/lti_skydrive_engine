require 'spec_helper'

module Skydrive
  describe FilesController do
    routes { Skydrive::Engine.routes }

    describe "before_filters" do
      it "should return unauthorized when skydrive token is not valid" do
        User.any_instance.stub(:valid_skydrive_token?).and_return(false)

        get 'index'
        expect(response.status).to eq(401)
      end
    end

  end
end
