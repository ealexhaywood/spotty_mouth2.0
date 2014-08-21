Factory.define :user do |user|
  user.username			"Will Ayd Example"
  user.email			"william.ayd@example.com"
  user.password			"foobar"
  user.password_confirmation	"foobar"
  user.image			nil
end

Factory.sequence :email do |n|
  "person-#{n}@example.com"
end

Factory.sequence :username do |n|
  "Person #{n}"
end

Factory.define :insult do |insult|
  insult.content "Foo bar"
  insult.association :insulter
  insult.association :insulted
end

Factory.sequence :content do |n|
  "Iterated Content #{n}"
end

Factory.define :comment do |comment|
  comment.content "Foo bar"
  comment.insult {|i| i.association(:insult)}
  comment.association :commenter
end

Factory.define :daily_question do |question|
  question.content "This is a question?"
end

Factory.define :daily_answer do |answer|
  answer.content "Foo bar"
  answer.user { |u| u.association(:user) }
  answer.daily_question { |u| u.association(:daily_question) }
end

Factory.define :answer_mark do |am|
  am.answer { |u| u.association(:daily_answer) }
end