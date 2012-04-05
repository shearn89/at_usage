# Load the rails application
require File.expand_path('../application', __FILE__)

Website::Application.configure do
  config.action_mailer.delivery_method = :smtp
  
  config.action_mailer.smtp_settings = {
    :address => "smtp.gmail.com",
    :port => "587",
    :domain => "shearn89.com",
    :authentication => "plain",
    :user_name => "bugs@isthat.it",
    :password => "bugtr4ck3r",
    :enable_starttls_auto => true
  }
end

# Initialize the rails application
Website::Application.initialize!