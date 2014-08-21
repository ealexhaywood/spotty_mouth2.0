class Comment < ActiveRecord::Base
  attr_accessible :insult_id, :commenter_id, :content
  attr_readonly :commenter_id, :insult_id
  
  belongs_to :insult
  belongs_to :commenter, :class_name => "User"
  
  validates :insult_id, :presence => true
  validates :commenter_id, :presence => true
  validates :content, :presence => true, 
		      :length => { :maximum => 255 }
  
  before_validation :strip_whitespace
  
  # number of records per page, from the will_paginate docs
  def per_page
    10
  end
  
  # takes a hash of finder conditions and returns a page number
  # returns 1 if nothing was found, as not to break pagination by passing page=0
  def last_page_number(conditions=nil)
    total = Comment.count(:conditions => conditions)
    [((total - 1) / per_page) + 1, 1].max
  end 
  
  private
    
    def strip_whitespace
      self.content = self.content.strip unless self.content.blank?
    end
end
