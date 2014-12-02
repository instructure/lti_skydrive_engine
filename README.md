SkydrivePro LTI Tool
======

[![Gem Version](https://badge.fury.io/rb/lti_skydrive.svg)](http://badge.fury.io/rb/lti_skydrive)

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

3. Configure your database by modifying test/dummy/config/database.yml.example
   it to use your database of choice.  The default configuration uses sqlite and
   should work out of the box.
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
   be `localhost:3000` and `http://localhost:3000/skydrive/microsoft_oauth` respectively.

   Once you have a client id and secret, copy your config/sharepoint.yml.example
   file to test/dummy/config/sharepoint.yml and replace the client_id and client_secret
   with your new key and secret.  The guid in sharepoint.yml is a constant
   provided by microsoft and is implementation indepenant.

5. Start the rails server
   ```
   cd test/dummy
   bundle install
   bundle exec rails server
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
   bundle exec rake skydrive:lti_key
   ```

9. Configure your tool consumer to use this tool. (https://www.edu-apps.org/tutorials.html)
   The config XML is located at /config on the LTI app itself. (ie `http://localhost:3000/config`)
   Additionally, this tool config requires a per installation parameter that tells
   the tool which office 365 instance it should be using.  Generally this domain
   follows the pattern <mysubdomain>-my.sharepoint.com.  You can verifiy your
   subdomain by navigating to your skydrive account via microsoft's web interface
   and checking the domain in the URL.  This domain can be added to the config
   via GET parameter. (ie `http://localhost:3000/config?sharepoint_client_domain=<mysubdomain>`)


React Build Notes
----------
* The react application can be packaged for production using a script. This will build a
  file called `bundle.js` and copy it to the asset pipeline.

  ```
  sh jsapp/script/build
  ```
