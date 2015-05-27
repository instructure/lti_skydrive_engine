require 'spec_helper'

module Skydrive
  describe LaunchController,  :type => :controller do

    account = Account.find_or_create_by!(key: "one", secret: "not_two" )
    let(:email) {'user@email.com'}
    let(:username) {'user'}
    let(:name) {'User'}
    let(:sharepoint_client_domain) {'login.windows.net'}

    let(:account) {account}
    let(:user) {account.users.find_or_initialize_by(email: 'user@email.com', username: 'user', name: 'User')}

    describe '#basic_launch' do

      before(:each) do
        tp = IMS::LTI::ToolProvider.new(nil, nil, {})
        tp.lis_person_contact_email_primary = email
        tp.set_custom_param('sharepoint_client_domain', 'test')
        tp.set_custom_param('masquerading_user_id', '$Canvas.masqueradingUser.userId')
        tp.user_id = username
        tp.lis_person_name_full = name

        allow_any_instance_of(LaunchController).to receive(:tool_provider).and_return(tp)
        controller.instance_variable_set("@account", account)
      end

      it "creates a new user" do
        expect(User.where(email: email).count).to be(0)

        post 'basic_launch', use_route: :skydrive
        expect(response).to be_redirect, response.body

        user = User.where(email: email).first!
        expect(user.email).to eq(email)
        expect(user.username).to eq(username)
        expect(user.name).to eq(name)

        expect(user.token).to be_a Token
      end

      it "updates existing users' name and email" do
        user.save
        tp = IMS::LTI::ToolProvider.new(nil, nil, {})
        tp.lis_person_contact_email_primary = "updated_email@example.com"
        tp.set_custom_param('sharepoint_client_domain', 'test')
        tp.user_id = username
        tp.lis_person_name_full = "Updated Name"
        allow_any_instance_of(LaunchController).to receive(:tool_provider).and_return(tp)

        post 'basic_launch', use_route: :skydrive
        expect(response).to be_redirect, response.body

        user = User.where(username: username).first!
        expect(user.email).to eq("updated_email@example.com")
        expect(user.username).to eq(username)
        expect(user.name).to eq("Updated Name")
        expect(user.token).to be_a Token
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
        expect(api_key.user).to eq(user)
      end

      it "cleans out expired tokens" do
        user.save
        api_key = user.session_api_key
        api_key.update_attributes(expired_at: Time.now)

        post 'basic_launch', use_route: :skydrive

        expect(ApiKey.where(id: api_key.id).count).to be(0)
      end
    end


    let(:masquerading_user_id) {'this_is_a_masqueraded_id'}
    let(:masquerading_email) {'masquerading_user@asd.com'}
    let(:masquerading_name) { 'Dr. masquerading name'}
    let(:masquerading_user) {account.users.find_or_initialize_by(email: masquerading_email, username: masquerading_user_id, name: masquerading_name)}

    describe '#basic_launch masqueraded' do

      before(:each) do
        tp = IMS::LTI::ToolProvider.new(nil, nil, {})
        tp.lis_person_contact_email_primary = email
        tp.set_custom_param('sharepoint_client_domain', 'test')
        tp.set_custom_param('masquerading_user_id', masquerading_user_id)
        tp.user_id = username
        tp.lis_person_name_full = name

        allow_any_instance_of(LaunchController).to receive(:tool_provider).and_return(tp)
        controller.instance_variable_set("@account", account)
      end

      it "creates a new user with masqueraded user" do
        expect(User.where(username: masquerading_user_id).count).to be(0)

        post 'basic_launch', use_route: :skydrive
        expect(response).to be_redirect, response.body

        user = User.where(username: masquerading_user_id).first!
        expect(user.email).to_not eq(email)
        expect(user.username).to eq(masquerading_user_id)
        expect(user.name).to_not eq(name)

        expect(user.token).to be_a Token
      end

      it "returns a valid oauth code with masqueraded user" do
        post 'basic_launch', use_route: :skydrive

        code = response.header['Location'].split('/').last
        api_key = ApiKey.where(oauth_code: code).first!
      end

      it "find existing users with masqueraded user" do
        masquerading_user.save

        post 'basic_launch', use_route: :skydrive
        code = response.header['Location'].split('/').last
        api_key = ApiKey.where(oauth_code: code).first!
        expect(api_key.user).to eq(masquerading_user)
      end

      it "find existing users with masqueraded user" do
        masquerading_user.save

        post 'basic_launch', use_route: :skydrive
        code = response.header['Location'].split('/').last
        api_key = ApiKey.where(oauth_code: code).first!

        user = api_key.user
        expect(user).to eq(masquerading_user)
        expect(user.email).to eq(masquerading_email)
        expect(user.username).to eq(masquerading_user_id)
        expect(user.name).to eq(masquerading_name)
      end


      it "doesn't update existing users' name and email if they are masquerading" do

        masquerading_user.save

        tp = IMS::LTI::ToolProvider.new(nil, nil, {})
        tp.lis_person_contact_email_primary = "updated_email@example.com"
        tp.set_custom_param('sharepoint_client_domain', 'test')
        tp.set_custom_param('masquerading_user_id', masquerading_user_id)
        tp.user_id = username
        tp.lis_person_name_full = "Updated Name"
        allow_any_instance_of(LaunchController).to receive(:tool_provider).and_return(tp)

        post 'basic_launch', use_route: :skydrive
        expect(response).to be_redirect, response.body

        user = User.where(username: masquerading_user_id).first!
        expect(user.email).to eq(masquerading_email)
        expect(user.username).to eq(masquerading_user_id)
        expect(user.name).to eq(masquerading_name)
        expect(user.token).to be_a Token
      end

      it "cleans out expired tokens with masqueraded user" do
        masquerading_user.save
        api_key = masquerading_user.session_api_key
        api_key.update_attributes(expired_at: Time.now)

        post 'basic_launch', use_route: :skydrive

        expect(ApiKey.where(id: api_key.id).count).to be(0)
      end
    end

    describe '#skydrive_authorized' do

      it "returns a skydrive_auth url when the skydrive token is invalid" do
        user.save

        allow_any_instance_of(LaunchController).to receive(:current_user).and_return(user)

        post 'skydrive_authorized', use_route: :skydrive
        expect(response.code).to eq("401")
        expect(response.body).to include sharepoint_client_domain
      end

      it "returns a 200 when the skydrive token is valid" do
        user.save
        user.token.update_attributes(access_token: 'token', expires_on: 1.week.from_now)

        allow_any_instance_of(LaunchController).to receive(:current_user).and_return(user)

        post 'skydrive_authorized', use_route: :skydrive
        expect(response).to be_success
      end
    end
  end
end
