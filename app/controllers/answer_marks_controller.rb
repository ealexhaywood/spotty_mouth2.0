class AnswerMarksController < ApplicationController
  before_filter :authenticate
  before_filter :allowed_to_create, :only => [:create]
  before_filter :allowed_to_destroy, :only => [:destroy]
  
  respond_to :html, :js
  
  def create
    @answer_mark = AnswerMark.new(:answer_id => params[:id])
    if @answer_mark.save
      respond_with(@answer_mark) do |format|
	format.html { redirect_to daily_question_path(@answer_mark.question) }
      end
    else
      daily_answer = DailyAnswer.find(params[:id])
      flash[:error] = "Setting could not be saved."
      redirect_to daily_question_path(daily_answer.daily_question)
    end
  end

  def destroy
    @answer_mark.destroy
    set_user_variables
    respond_with(@answer_mark) do |format|
      format.html { redirect_to daily_question_path(@answer_mark.question) }
    end
  end
  
  def set_user_variables
    @user_answers_ids = current_user.daily_answers.
	where(:daily_question_id => @answer_mark.question_id)
  end

  
  private
    
    def allowed_to_create
      daily_answer = DailyAnswer.find(params[:id])
      redirect_to(root_path) unless current_user?(daily_answer.user)
    end
    
    def allowed_to_destroy
      @answer_mark = AnswerMark.find(params[:id])
      redirect_to(root_path) unless current_user?(@answer_mark.user)
    end
end
