class DailyQuestion < ActiveRecord::Base
  attr_accessible :content
  cattr_reader :per_page
  
  @@per_page = 31
  
  has_many :daily_answers, :dependent => :destroy
  has_many :answer_marks, :foreign_key => :question_id,
			  :dependent => :destroy
  has_many :marked_answers, :through => :answer_marks, :source => :answer
  
  validates :content, :presence => true,
		      :length => { :maximum => 255 }
  
  before_validation :strip_whitespace
  
  default_scope :order => 'daily_questions.created_at DESC'
  
  private
  
    def strip_whitespace
      self.content = self.content.strip unless self.content.blank?
    end
end
