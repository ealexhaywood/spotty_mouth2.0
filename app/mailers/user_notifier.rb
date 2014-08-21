class UserNotifier < ActionMailer::Base
  
  default :from => "spottymouth@gmail.com"
  
  def new_password(user, new_password)
    @user = user
    @new_password = new_password
    mail(:to => @user.email,
         :subject => 'Your new password') do |format|
	    format.html
	    format.text
    end
  end
end