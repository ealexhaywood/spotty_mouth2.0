class DailyAnswersController < ApplicationController
  before_filter :authenticate
  before_filter :allowed_users, :only => [:destroy]
  def create
    @daily_answer = current_user.daily_answers.build(params[:daily_answer])
    @daily_answer.daily_question_id = params[:daily_question_id]
    if @daily_answer.save
      flash[:success] = "Answer saved."
      redirect_to daily_question_path(@daily_answer.daily_question)
    else
      flash[:error] = "Answer could not be saved."
      @daily_question = DailyQuestion.find(params[:daily_question_id])
      @daily_answers = []
      render 'daily_questions/show'
    end
  end
  
  def destroy
    @daily_answer = DailyAnswer.find(params[:id])
    @daily_answer.destroy
    redirect_to daily_question_path(@daily_answer.daily_question)
  end
  
  private
  
    def allowed_users
      @daily_answer = DailyAnswer.find(params[:id])
      redirect_to root_path unless ((current_user == @daily_answer.user) || current_user.admin?)
    end
end
