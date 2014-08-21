module DailyQuestionsHelper
  def question_months
    DailyQuestion.all(:select => "created_at").group_by { |m| m.created_at.beginning_of_month }
  end
end
