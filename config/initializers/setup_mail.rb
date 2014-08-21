  ActionMailer::Base.smtp_settings = {
    :enable_starttls_auto => true,  
    :address            =>  'smtp.gmail.com',
    :port               =>  587,
    :tls                =>  true,
    :domain             => 'gmail.com', #you can also use google.com
    :authentication     => :plain,
    :user_name          => 'spottymouth@gmail.com',
    :password           => 'Bosstweed1'
  }
  
ActionMailer::Base.register_interceptor(DevelopmentMailInterceptor) if Rails.env.development?