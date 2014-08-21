class DailyQuestionsController < ApplicationController
  before_filter :admin_user, :except => [:index, :show, :archive]
  
  def index
    @daily_question = DailyQuestion.first
    @daily_answers = @daily_question.daily_answers.paginate(
			:page => params[:page]) unless @daily_question.nil?
    set_user_variables if signed_in?
    @daily_answer = DailyAnswer.new
  end

  def show
    @daily_question = DailyQuestion.find(params[:id])
    @daily_answers = @daily_question.daily_answers.paginate(
			:page => params[:page]) unless @daily_question.nil?
    set_user_variables if signed_in?
    @daily_answer = DailyAnswer.new
  end
  
  def archive
    date = params[:timeframe].blank? ? nil : Time.parse(params[:timeframe])
    unless date.nil?
      @daily_questions = DailyQuestion.all(:conditions => 
                              { :created_at => date.beginning_of_month..date.end_of_month }).
			      paginate(:page => params[:page])
    else
      @daily_questions = DailyQuestion.paginate(:page => params[:page])
    end
  end

  def new
    @daily_question = DailyQuestion.new
  end

  def create
    @daily_question = DailyQuestion.new(params[:daily_question])
    if @daily_question.save
      flash[:success] = "Question added."
      redirect_to @daily_question
    else
      flash[:error] = "The question could not be saved."
      render 'daily_questions/new'
    end
  end

  def destroy
    @daily_question = DailyQuestion.find(params[:id])
    @daily_question.destroy
    flash[:success] =  "Question destroyed."
    redirect_to daily_questions_path
  end
  
  def set_user_variables
    # @user_answers = @daily_answers.find_all { 
    #  |u| u.user_id == current_user.id }.map { |u| u.id }
    @already_answered = true if current_user.already_marked_answer?(@daily_question)
  end
end
