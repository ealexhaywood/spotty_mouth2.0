class CommentsController < ApplicationController
  before_filter :authenticate, :except => [:index]
  before_filter :allowed_users, :only => [:destroy]
  
  def index
    @insult = Insult.find_by_id(params[:insult_id])
    @comments = @insult.comments.paginate(:page => params[:page], :per_page => 10)
    @comment = Comment.new
  end
  
  def new
    @insult = Insult.find_by_id(params[:insult_id])
    @comment = Comment.new
  end
  
  def create
    @insult = Insult.find_by_id(params[:insult_id])
    @comment = @insult.comments.build(:commenter_id => current_user.id,
                                      :content => params[:comment][:content])
    if @comment.save
      flash[:success] = "Comment added!"
      redirect_to insult_comments_path(@insult, 
                   :page => @comment.last_page_number(:insult_id => @insult.id))
    else
      flash[:error] = "You Fool!  The comment could not be added."
      @title = "Comment creation Error"
      render 'comments/new'
    end
  end
  
  def destroy
    @comment = Comment.find_by_id(params[:id])
    @insult = @comment.insult
    @comment.destroy
    flash[:success] = "Comment deleted."
    redirect_to insult_comments_path(@insult)
  end
  
  private
  
    def allowed_users
      @comment = Comment.find(params[:id])
      redirect_to(root_path) unless current_user.comment_delete_power?(@comment)
    end
end