class AnswerMark < ActiveRecord::Base
  attr_accessible :answer_id
  
  belongs_to :user
  belongs_to :question, :class_name => "DailyQuestion"
  has_one :answer, :class_name => "DailyAnswer", :dependent => :nullify
  
  validates_uniqueness_of :user_id, :scope => :question_id
  validates_uniqueness_of :answer_id
  
  validates :user_id, :presence => true
  validates :answer_id, :presence => true
  validates :question_id, :presence => true
  
  before_validation :assign_attributes
  
  private
  
    def assign_attributes
      unless self.answer_id.blank?
	da = DailyAnswer.find(self.answer_id)
	self.answer = da
	self.user = da.user
	self.question = da.daily_question
      end
	# self.user = DailyAnswer.find(self.answer_id).user unless self.answer_id.blank?
    end
end
