$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "skydrive/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lti_skydrive"
  s.version     = Skydrive::VERSION
  s.licenses    = ['MIT']
  s.authors     = ["Brad Humphrey"]
  s.email       = ["brad@instructure.com"]
  s.homepage    = "https://www.edu-apps.org/"
  s.summary     = "Microsoft SkydrivePro integration"
  s.description = "Microsoft SkydrivePro integration"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.0.0"
  s.add_dependency "active_model_serializers", "~> 0.8.0"
  s.add_dependency "ims-lti"
  s.add_dependency "rest-client"
  s.add_dependency "curb"
  s.add_dependency "mimemagic"
  
  s.add_development_dependency "sqlite3"
end
