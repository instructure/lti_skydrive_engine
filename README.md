SkydrivePro LTI Tool
======

The SkydrivePro LTI tool provides a method for using LTI to access and return
SkydrivePro files to a ToolConsumer.  This app uses the unofficial LTI content
extension to return file information to the tool consumer.  For more information
on LTI and the content extenstion see https://www.edu-apps.org/code.html and
https://www.edu-apps.org/extensions/content.html.

Part of the goal with this project is to create a sessionless, API driven, LTI
application.  LTI applications are launched via form post and generally embeded
in an iframe.  Several browsers block the creation of cookies, and therefore
sessions, which can make tracking state within an LTI tool difficult.  This app
uses tokens and a robust API, along with a front-end heavy ember application to
provide the stateful experience while avoiding the restrictions associated with
sessions.


Getting Started
-----

1. Install bundler and then install the project gems (http://bundler.io)
   ```
   gem install bundler
   bundle install
   ```

2. Install ember tools and build your ember app (https://github.com/rpflorence/ember-tools):
   ```
   cd /path/to/app
   npm install -g ember-tools
   ember build
   ```
   Once ember tools is installed you can use guard to watch your ember app and
   build your application on the fly:

   ```
   bundle exec guard
   ```

3. Configure your database by copying config/database.yml.example to
   config/database.yml and then modifying it to use your database of choice.
   The default configuration uses sqlite and should work out of the box.
   ```
   cp config/database.yml.example config/database.yml
   bundle exec rake db:migrate
   ```

4. Obtain a client_id and client_secret from microsoft.  This will be used to
   request sharepoint API keys for your users.  You can create your own client ids
   at https://sellerdashboard.microsoft.com/Keys.  You will need to create an
   account in order to get keys here.

   Microsoft is very picky about the app domain and redirect url matching your
   app exactly.  The redirect url will always be <yourhost>/microsoft_oauth.  If
   you are running this app in development, your domain and url will most likely
   be `localhost:3000` and `http://localhost:3000/microsoft_oauth` respectively.

   Once you have a client id and secret, copy your config/sharepoint.yml.example
   file to config/sharepoint.yml and replace the client_id and client_secret
   with your new key and secret.  The guid in sharepoint.yml is a constant
   provided by microsoft and is implementation indepenant.

5. Start the rails server
   ```
   rails server
   ```

6. Do a simple sanity test by navigating to your app in a browser (ie `http://locahost:3000`).
   You should see a simple error informing you that your app was not launched
   correctly.

7. Ensure that the test suite is passing
   ```
   RAILS_ENV=test bundle exec rake db:migrate
   bundle exec rspec spec/
   ```

8. Generate a consumer key/secret pair to use with this tool.
   ```
   bundle exec script/generate_lti_key
   ```

9. Configure your tool consumer to use this tool. (https://www.edu-apps.org/tutorials.html)
   The config XML is located at /config on the LTI app itself. (ie `http://localhost:3000/config`)
   Additionally, this tool config requires a per installation parameter that tells
   the tool which office 365 instance it should be using.  Generally this domain
   follows the pattern <mysubdomain>-my.sharepoint.com.  You can verifiy your
   subdomain by navigating to your skydrive account via microsoft's web interface
   and checking the domain in the URL.  This domain can be added to the config
   via GET parameter. (ie `http://localhost:3000/config?sharepoint_client_domain=<mysubdomain>`)


Production Notes
----------
* The ember application can be packaged for production (or development) use with
  a rake task
  ```
  bundle exec rake build:ember
  ```
  This task uses the RAILS_ENV parameter, so when it is called in a development
  environment it will build the application with development friendly versions
  of ember and when run in production it will use the production version of ember
  and minify the application.  If you want to prebuild the application before
  deploying, or you want to test your production build simply pass in the correct
  environment:
  ```
  bundle exec rake build:ember RAILS_ENV=production
  ```
