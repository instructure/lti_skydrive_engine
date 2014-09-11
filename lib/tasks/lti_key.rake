namespace :skydrive do
  desc "Generate a Skydrive LTI Key and Secret"
  task :lti_key => :environment do
    key = Skydrive::Account.new_key
    puts "key:    #{key.key}"
    puts "secret: #{key.secret}"
  end
end

