class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :authenticate2, :only => [:new, :create]
  before_filter :admin_user,	:only => :destroy
  before_filter :correct_user, 	:only => :update

  def show
    @user = User.find(params[:id])
    @insults = @user.insults.paginate(:page => params[:page])
    @insult = Insult.new
    @title = helpers.sanitize(@user.username, :tags => "")
    @daily_question = DailyQuestion.first
    if @daily_question && @user.already_marked_answer?(@daily_question)
      @user_marked_answer = AnswerMark.find_by_question_id_and_user_id(
			      @daily_question.id, @user.id)
    end
  end

  def new
    @user = User.new
    @title = "Sign up"
  end
  
  def create
    @user = User.new(params[:user])
      if @user.valid? && verify_recaptcha()
	@user.save
	sign_in @user
	flash[:success] = "Successful Registration!"
	redirect_to @user
      else
	if !verify_recaptcha()
	  flash[:error] = "The verification was not correct.  Please try again."
	end
	# Clear passwords
	@user.password = ""
	@user.password_confirmation = ""
	@title = "Sign up"
	render 'new'
      end
  end
  
  def edit
    @user = current_user
    @title = current_user.username + " Edit"
  end
  
  def update
    @user = current_user
    @user.image = params[:user][:image]
    begin
      @user.update_attributes!(params[:user])
      flash[:success] = "Profile updated successfully!"
      redirect_to user_path(@user)
    rescue
      flash[:error] = "Changes could not be saved."
      @user.errors.add(:upload, @user.image_integrity_error) if @user.image_integrity_error
      render 'edit'
    end
  end
  
  def destroy
    # Uses current_user.id, which by default must be an admin ID, and checks
    # if user to delete is the admin itself, in which case an error is thrown
    @user = User.find(params[:id])
    if current_user.id == @user.id
      flash[:error] = "Deletion of self as admin is not allowed."
    else
    @user.destroy
    flash[:success] = "User destroyed."
    end
    redirect_to root_path
  end
  
  def following 
    @user = User.find(params[:id])
    @users = @user.following.paginate(:page => params[:page])
    render 'show_follow'
  end
  
  def followers
    @user = User.find(params[:id])
    @users = @user.followers.paginate(:page => params[:page])
    render 'show_follow'
  end
  
  def voters_for
    @user = User.find(params[:id])
    @voters = @user.votes.where(:vote => true).map(&:voter).uniq.paginate(:page => params[:page])
    render 'shared/show_voters'
  end
  
  def voters_against
    @user = User.find(params[:id])
    @voters = @user.votes.where(:vote => false).map(&:voter).uniq.paginate(:page => params[:page])
    render 'shared/show_voters'
  end
  
  def beef_with
    @user = User.find(params[:id])
    t = Insult.where("(insulter_id = :current_user AND insulted_id = :user) 
                            OR (insulter_id = :user AND insulted_id = :current_user)",
                     { :current_user => current_user, :user => @user })
    @insults = t.select("*").paginate(:page => params[:page])
  end
  
  # To include sanitize method
  def helpers
    Helper.instance
  end

  class Helper
    include Singleton
    include ActionView::Helpers::TextHelper
  end

  private
  
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end
end

