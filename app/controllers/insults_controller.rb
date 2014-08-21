class InsultsController < ApplicationController
  before_filter :authenticate, :only => [:index, :create, :voters_for, :voters_against]
  before_filter :allowed_users, :only => [:destroy]
  
  def index
    @user = User.find(params[:user_id])
    @insults = Insult.where("insulter_id = ?", params[:user_id]).
	paginate(:page => params[:page])
    @title = "#{@user.username}'s Insults"    
  end
  
  def create
    @insulted = User.find(params[:user_id])
    @insult = @insulted.insults.build(:insulter_id => current_user.id,
                                      :content => params[:insult][:content])
    if @insult.save
      flash[:success] = "You just spat some fire."
      redirect_to user_path(@insulted)
    else
      flash[:error] = "Your game is too weak."
      @user = @insulted
      @insults = @user.insults.paginate(:page => params[:page])
      render 'users/show'
    end
  end
  
  def destroy
    @insult = Insult.find(params[:id])
    @insulted = @insult.insulted
    @insult.destroy
    flash[:success] = "Insult deleted."
    redirect_to user_path(@insulted)
  end
  
  def voters_for
    @insult = Insult.find(params[:id])
    @voters = @insult.votes.where(:vote => true).map(&:voter).uniq.paginate(:page => params[:page])
    render 'shared/show_voters'
  end
  
  def voters_against
    @insult = Insult.find(params[:id])
    @voters = @insult.votes.where(:vote => false).map(&:voter).uniq.paginate(:page => params[:page])
    render 'shared/show_voters'
  end
  
  private
    def allowed_users
      @insult = Insult.find(params[:id])
      if !signed_in?
	redirect_to(root_path)
      else
	redirect_to(root_path) unless current_user.insult_delete_power?(@insult)
      end
    end
end
