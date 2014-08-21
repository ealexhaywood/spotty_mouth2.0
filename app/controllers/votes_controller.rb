class VotesController < ApplicationController
  before_filter :authenticate
  
  respond_to :html, :js
  
  def vote_up_user
    @voted_on_user = User.find(params[:id])
    current_user.vote_exclusively_for(@voted_on_user)
    respond_with(@voted_on_user, :location => user_path(@voted_on_user)) do |format|
      format.html { redirect_to user_path(@voted_on_user) }
    end
  end
  
  def vote_down_user
    @voted_on_user = User.find(params[:id])
    current_user.vote_exclusively_against(@voted_on_user)
    respond_with(@voted_on_user, :location => user_path(@voted_on_user)) do |format|
      format.html { redirect_to user_path(@voted_on_user) }
    end
  end
  
  def vote_up_insult
    @voted_on_insult = Insult.find(params[:id])
    current_user.vote_exclusively_for(@voted_on_insult)
    respond_with(@voted_on_insult, :location => user_path(@voted_on_insult.insulted)) do |format|
      format.html { redirect_to user_path(@voted_on_insult.insulted) }
    end
  end
  
  def vote_down_insult
    @voted_on_insult = Insult.find(params[:id])
    current_user.vote_exclusively_against(@voted_on_insult)
    respond_with(@voted_on_insult, :location => user_path(@voted_on_insult.insulted)) do |format|
      format.html { redirect_to user_path(@voted_on_insult.insulted) }
    end
  end
end
