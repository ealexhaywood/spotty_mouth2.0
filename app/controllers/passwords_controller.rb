class PasswordsController < ApplicationController
  # Adapted from http://www.justinbritten.com/work/2008/03/how-to-change-or-reset-your-password-with-restful_authentication/
  before_filter :authenticate, :only => [:edit, :update]
  before_filter :authenticate2, :only => [:new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  
  def new
    @title = "Forgot Password"
  end
  
  def create
    @user = User.find_by_email(params[:email])
    if !@user.nil? && verify_recaptcha()
      @user.updating_password = true
      @new_password = random_password
      UserNotifier.new_password(@user, @new_password).deliver
      @user.update_attributes(:password => @new_password, 
                             :password_confirmation => @new_password)
      flash[:success] = "A new password has been sent to your email."
      redirect_to root_path
    else
      if !verify_recaptcha()
	flash[:error] = "The verification was not correct.  Please try again."
      else
	flash[:error] = "The provided email account does not exist."
      end
      render 'passwords/new'
    end
  end
  
  def edit
    @user = current_user
  end
  
  def update      
    @user = current_user
    # Try to authenticate current user with old password
    # If unsuccessfuly send back to edit page.
    if !User.authenticate(@user.email,
                         params[:old_password])
      flash[:error] = "User could not be verified."
      render 'edit'
    else
    # If new password could be saved, proceed.  Else
    # Return to edit page
      @user.updating_password = true
      if @user.update_attributes(params[:user])
	flash[:success] = "Password successfully changed."
	redirect_to user_path(@user)
      else
	@user.password = ""
	@user.password_confirmation = ""
	flash[:error] = "Password could not be changed."
	params[:user] = nil
	render 'edit'
      end
    end
  end
  
  private
  
    def random_password(len=20)
      chars = (("a".."z").to_a + ("1".."9").to_a)- %w(i o 0 1 l 0)
      newpass = Array.new(len, '').collect{chars[rand(chars.size)]}.join
    end
  
    def correct_user
      @user = User.find(params[:user_id])
      redirect_to(root_path) unless current_user?(@user)
    end
end