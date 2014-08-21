class DailyAnswer < ActiveRecord::Base
  attr_accessible :content, :daily_question_id, :user_id, :answer_mark_id
  attr_readonly :daily_question_id, :user_id
  
  belongs_to :daily_question
  belongs_to :user
  belongs_to :answer_mark
  
  validates :user_id, :presence => true
  validates :daily_question_id, :presence => true
  validates :content, :presence => true,
		      :length => { :maximum => 255 }
  
  before_validation :strip_whitespace
  
  default_scope :order => 'daily_answers.created_at'
  
  private
  
    def strip_whitespace
      self.content = self.content.strip unless self.content.blank?
    end
end
