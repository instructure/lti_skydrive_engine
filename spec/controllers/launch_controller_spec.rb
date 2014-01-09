require 'spec_helper'

module Skydrive
  describe LaunchController do
    let(:email) {'user@email.com'}
    let(:username) {'user'}
    let(:name) {'User'}
    let(:sharepoint_client_domain) {'test-my.sharepoint.com'}

    let(:user) {User.new(email: 'user@email.com', username: 'user', name: 'User')}

    describe '#basic_launch' do
      before(:each) do
        tp = IMS::LTI::ToolProvider.new(nil, nil, {})
        tp.lis_person_contact_email_primary = email
        tp.set_custom_param('sharepoint_client_domain', 'test')
        tp.user_id = username
        tp.lis_person_name_full = name

        LaunchController.any_instance.stub(tool_provider: tp)
      end

      it "creates a new user" do
        user = User.where(email: email).count.should == 0

        post 'basic_launch', use_route: :skydrive
        response.should be_redirect, response.body

        user = User.where(email: email).first!
        user.email.should == email
        user.username.should == username
        user.name.should == name

        user.token.should be_a Token
        user.token.client_domain.should == sharepoint_client_domain
      end

      it "returns a valid oauth code" do
        post 'basic_launch', use_route: :skydrive

        code = response.header['Location'].split('/').last
        api_key = ApiKey.where(oauth_code: code).first!
      end

      it "find existing users" do
        user.save

        post 'basic_launch', use_route: :skydrive
        code = response.header['Location'].split('/').last
        api_key = ApiKey.where(oauth_code: code).first!
        api_key.user.should == user
      end

      it "cleans out expired tokens" do
        user.save
        api_key = user.session_api_key
        api_key.update_attributes(expired_at: Time.now)

        post 'basic_launch', use_route: :skydrive

        ApiKey.where(id: api_key.id).count.should == 0
      end
    end

    describe '#skydrive_authorized' do

      it "returns a skydrive_auth url when the skydrive token is invalid" do
        user.save
        user.token = Token.create(client_domain: sharepoint_client_domain)

        LaunchController.any_instance.stub(current_user: user)

        post 'skydrive_authorized', use_route: :skydrive
        response.code.should == "401"
        response.body.should be_include sharepoint_client_domain
      end

      it "returns a 200 when the skydrive token is valid" do
        user.save
        user.token = Token.create(client_domain: sharepoint_client_domain, access_token: 'token', expires_on: 1.week.from_now)

        LaunchController.any_instance.stub(current_user: user)

        post 'skydrive_authorized', use_route: :skydrive
        response.should be_success
      end
    end
  end
end
