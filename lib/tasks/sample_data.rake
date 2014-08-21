namespace :db do
  desc "Fill database with sample data"
  task :populate => :environment do
    if !Rails.env.production?
      require 'faker'
      Rake::Task['db:reset'].invoke
      make_users
      make_insults
      make_relationships
      make_comments
      make_questions
      make_answers
    end
  end
end

def make_users
  admin = User.create!(:username => "Example User",
                       :email => "example@example.com",
                       :password => "foobar",
                       :password_confirmation => "foobar")
  admin.toggle!(:admin)
  99.times do |n|
    username = Faker::Name.name
    email = "example-#{n+1}@railstutorial.org"
    password = "password"
    blurb = "About Me \n New Line"
    User.create!(:username => username,
		 :email => email,
		 :password => password,
		 :password_confirmation => password,
		 :blurb => blurb)
  end
end 

def make_insults
  User.all(:limit => 6).each do |user|
    50.times do |n|
      user.insults.create!(:content => Faker::Lorem.sentence(5), :insulter_id => (n+1))
    end
  end
end

def make_relationships
  users = User.all
  user = users.first
  following = users[1..50]
  followers = users[3..40]
  following.each { |followed| user.follow!(followed) }
  following.each { |follower| follower.follow!(user) }
end

def make_comments
  User.all(:limit => 6).each do |user|
    user.insults.all(:limit => 10).each do |insult|
      50.times do |n|
	insult.comments.create!(:content => Faker::Lorem.sentence(5), :commenter_id => (n+1))
      end
    end
  end
end

def make_questions
  31.times do 
    DailyQuestion.create!(:content => Faker::Lorem.sentence(15))
  end
end

def make_answers
  DailyQuestion.all.each do |question|
    31.times do |n|
      question.daily_answers.create!(:content => Faker::Lorem.sentence(5), 
                                     :user_id => (n+1))
    end
  end
end
