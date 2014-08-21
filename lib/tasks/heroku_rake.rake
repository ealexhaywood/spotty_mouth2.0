namespace :db do
  desc "Fill database with personal data"
  task :populate => :environment do
    if Rails.env.production?
      Rake::Task['db:reset'].invoke
      make_admin
    end
  end
end

def make_admin
    admin = User.create!(:username => "Frizzle Fry",
		 :email => "william.ayd@gmail.com",
		 :password => "password123",
		 :password_confirmation => "password123")
	admin.toggle!(:admin)
end 
