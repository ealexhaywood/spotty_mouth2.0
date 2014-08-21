require 'digest'
class User < ActiveRecord::Base
  # Potential TO-DO: validate image size before caching
  attr_accessor :password, :updating_password
  attr_accessible :username, :email, :password, :password_confirmation, :image, :blurb
  attr_readonly :username, :email
  mount_uploader :image, ImageUploader
  
  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  
  has_many :insults, :foreign_key => :insulted_id,
		     :dependent => :destroy  
  has_many :reverse_insults, :foreign_key => :insulter_id,
			     :class_name => "Insult",
			     :dependent => :destroy
  has_many :relationships, :foreign_key => :follower_id,
			   :dependent => :destroy
  has_many :reverse_relationships, :foreign_key => :followed_id,
				   :class_name => "Relationship",
				   :dependent => :destroy
  has_many :following, :through => :relationships, :source => :followed
  has_many :followers, :through => :reverse_relationships, :source => :follower
  has_many :comments, :foreign_key => :commenter_id,
		      :dependent => :destroy
  has_many :daily_answers, :dependent => :destroy
  has_many :answer_marks, :dependent => :destroy
  has_many :marked_answers, :through => :answer_marks, :source => :answer
  
  validates :username, :presence => true,
		       :uniqueness => { :case_sensitive => false },
		       :length => { :minimum => 4,
                                :maximum => 30 }
  
  validates :email, :presence => true,
		    :format => { :with => email_regex },
		    :uniqueness => { :case_sensitive => false }
  
  validates :password, :presence => true,
		       :confirmation => true,
		       :length => { :within => 6..40 },# Automatically create the virtual attribute 'password confirmation'
		       :if => :should_validate_password?
  
  validates_length_of :blurb, :maximum => 600
  
  before_validation :strip_whitespace
  before_save :encrypt_password, :if => :should_validate_password?
  
  acts_as_voter
  acts_as_voteable
  
  def should_validate_password?
    updating_password || new_record?
  end
  
  def has_password?(submitted_password)
    encrypted_password == encrypt(submitted_password)
  end
  
  def self.authenticate(email, submitted_password)
    user = find_by_email(email)
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
    return nil
  end
  
  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  def following?(followed)
    relationships.find_by_followed_id(followed.id)
  end
  
  def follow!(followed)
    relationships.create!(:followed_id => followed.id)
  end
  
  def unfollow!(followed)
    relationships.find_by_followed_id(followed.id).destroy
  end
  
  def already_marked_answer?(question)
    marked_answers.find_by_daily_question_id(question.id)
  end
  
  # Kept getting undefined method when trying to inherit this method, so 
  # wrote this custom override
  def new_record?
    self.id.nil? ? true : false
  end
  
  def add_insult!(insulter, content)
    self.insults.create!(:insulter_id => insulter.id, :content => content)
  end
  
  def insult_delete_power?(insult)
    (self == insult.insulted) || (self == insult.insulter) || self.admin?
  end
  
  def comment_delete_power?(comment)
    (self == comment.commenter) || (self == comment.insult.insulted) || self.admin?
  end
  
  def feed
    Insult.from_users_followed_by(self)
  end
  
  private
  
    def strip_whitespace
      self.username = self.username.strip unless self.username.blank?
      self.blurb = self.blurb.strip unless self.blurb.blank?
    end
    
    def encrypt_password
      self.salt = make_salt if new_record?
      self.encrypted_password = encrypt(password)
    end
    
    def encrypt(string)
      secure_hash("#{salt}--#{string}")
    end
    
    def make_salt
      secure_hash("#{Time.now.utc}--#{password}")
    end
    
    def secure_hash(string)
      Digest::SHA2.hexdigest(string)
    end
    
    def image_size_validation
      errors[:image] << "should be less than 2 MB" if image.size > 2.megabytes
    end
end
