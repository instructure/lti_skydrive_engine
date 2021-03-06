Skydrive::Engine.routes.draw do
  root "ember#index"

  get 'health_check' => 'ember#health_check'
  get 'new_authentication' => 'ember#new_authentication', as: :new_authentication
  post 'generate_authentication' => 'ember#generate_authentication', as: :generate_authentication
  get '/download/file' => 'files#download', as: :download

  scope "api/v1" do
    resources :users, except: [:new, :edit]
    get 'files' => 'files#index'
    get 'skydrive_authorized' => 'launch#skydrive_authorized'
  end

  post 'session' => 'session#create'

  #LTI launch paths
  match 'launch' => 'launch#basic_launch', :as => :launch, :via => [:get, :post]
  get 'skydrive_logout' => 'launch#skydrive_logout'
  get 'backdoor' => 'launch#backdoor_launch'
  get 'microsoft_oauth' => 'launch#microsoft_oauth'
  post 'microsoft_oauth' => 'launch#app_redirect'

  get 'config' => 'launch#xml_config'

  post 'oauth2/token' => 'api_keys#oauth2_token'
  match 'error' => 'launch#launch_error', :via => [:get, :post]

  # forward all other requests to react application
  get '*path', to: 'ember#index'
end
