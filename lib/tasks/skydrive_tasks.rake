namespace :skydrive do
  task :lti_key => :environment do
    key = Skydrive::LtiKey.new_key
    puts "key:    #{key.key}"
    puts "secret: #{key.secret}"
  end
end

