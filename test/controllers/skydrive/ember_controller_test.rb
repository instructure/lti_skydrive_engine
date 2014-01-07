require 'test_helper'

module Skydrive
  class EmberControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end

  end
end
