class Insult < ActiveRecord::Base
  attr_accessible :content, :insulter_id
  attr_readonly :insulted_id, :insulter_id
  
  belongs_to :insulted, :class_name => "User"
  belongs_to :insulter, :class_name => "User"
  
  has_many :comments, :foreign_key => :insult_id,
		      :dependent => :destroy
  
  validates :content, :presence => true, 
		      :length => { :maximum => 255 }
  validates :insulted_id, :presence => true
  validates :insulter_id, :presence => true
  
  before_validation :strip_whitespace
  
  default_scope :order => 'insults.created_at DESC'
  
  # Return insults from the users being followed by the given user.
  scope :from_users_followed_by, lambda { |user| followed_by(user) }
  
  acts_as_voteable
  
  private
    # Return an SQL condition for users followed by the given user.
    # We include the user's own id as well.
    def self.followed_by(user)
      followed_ids = Relationship.where("follower_id = ?", user.id)
      followed_ids = followed_ids.select("followed_id")
      t = self.where("insulted_id IN (#{followed_ids.to_sql}) OR insulter_id IN (#{followed_ids.to_sql})")
      t.where("created_at > ?", 3.days.ago)
    end
    
    def strip_whitespace
      self.content = self.content.strip unless self.content.blank?
    end
end
