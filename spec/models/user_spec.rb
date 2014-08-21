require 'spec_helper'

describe User do
  
  before(:each) do
    @attr = { 
      :username => "Example User", 
      :email => "user@example.com",
      :password => "foobar",
      :password_confirmation => "foobar",
      :blurb => "About Me"
    }
  end
  
  it "should create a new instance given valid attributes" do
    User.create!(@attr)
  end
  
  it "should require a username" do
    no_name_user = User.new(@attr.merge(:username => ""))
    no_name_user.should_not be_valid
  end
  
  it "should require an email address" do
    no_email_user = User.new(@attr.merge(:email => ""))
    no_email_user.should_not be_valid
  end
  
  it "should reject names that are too long" do
    long_name = "a" * 31
    long_name_user = User.new(@attr.merge(:username => long_name))
    long_name_user.should_not be_valid
  end
  
  it "should accept valid email addresses" do
    addresses = %w[user@foo.com THE_USER@foo.bar.org first.last@foo.jp]
    addresses.each do |address|
      valid_email_user = User.new(@attr.merge(:email => address))
      valid_email_user.should be_valid
    end
  end
  
  it "should reject invalid email addresses" do
    addresses = %w[user@foo,com user_at_foo.org example.user@foo.]
    addresses.each do |address|
      invalid_email_user = User.new(@attr.merge(:email => address))
      invalid_email_user.should_not be_valid
    end
  end
  
  it "should reject duplicate email addresses" do
    User.create!(@attr)
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should reject email addresses identical up to case" do
    upcased_email = @attr[:email].upcase
    User.create!(@attr.merge(:email => upcased_email))
    user_with_duplicate_email = User.new(@attr)
    user_with_duplicate_email.should_not be_valid
  end
  
  it "should have an image attribute" do
    user = User.create!(@attr)
    user.should respond_to(:image)
  end
  
  it "should have a blurb attribute" do
    user = User.create!(@attr)
    user.should respond_to(:blurb)
  end
  
  it "should have an insults method" do
    user = User.create!(@attr)
    user.should respond_to(:insults)
  end
  
  it "should reject blurbs that are too long" do
    @long_blurb = "a" * 601
    long_blurb_user = User.new(@attr.merge(:blurb => @long_blurb))
    long_blurb_user.should_not be_valid
  end
  
  describe "attribute strip" do
    
    it "should remove leading and trailing whitespace in the username" do
      user = User.create!(@attr.merge(:username => "  Username  "))
      user.username.should == "Username"
    end
    
    it "should reject stripped usernames that are too short" do
      user = User.new(@attr.merge(:username => "  aaa  "))
      user.should_not be_valid
    end
    
    it "should remove leading and trailing whitespace in the blurb" do
      user = User.create!(@attr.merge(:blurb => "   Blurb Content  "))
      user.blurb.should == "Blurb Content"
    end
    
    it "should reject duplicates after stripping whitespace" do
      user = User.create!(@attr)
      second_user = User.new(@attr.merge(:username => "  Example User  "))
      second_user.should_not be_valid
    end
  end
  
  describe "password validations" do
    
    it "should require a password" do
      User.new(@attr.merge(:password => "", :password_confirmation => "")).
      should_not be_valid
    end
    
    it "should require a mataching password confirmation" do
      User.new(@attr.merge(:password_confirmation => "invalid")).
      should_not be_valid
    end
    
    it "should reject short passwords" do
      short = "a" * 5
      hash = @attr.merge(:password => short, :password_confirmation => short)
      User.new(hash).should_not be_valid
    end
    
    it "should reject long passwords" do
      long = "a" * 41
      hash = @attr.merge(:password => long, :password_confirmation => long)
      User.new(hash).should_not be_valid
    end
  end
  
  describe "password encryption" do
            
    before(:each) do
      @user = User.create!(@attr)
    end
    
    it "should have an encrypted password attribute" do
      @user.should respond_to(:encrypted_password)
    end
    
    it "should set the encrypted password" do
      @user.encrypted_password.should_not be_blank
    end
    
    describe "has_password? method" do
            
      it "should be true if the passwords match" do
	@user.has_password?(@attr[:password]).should be_true
      end
      
      it "should be false if the passwords don't match" do
	@user.has_password?("invalid").should be_false
      end
    end
    
    describe "authenticate method" do
      
      it "should return nil on email/password mismatch" do
	wrong_password_user = User.authenticate(@attr[:email], "wrongpass")
	wrong_password_user.should be_nil
      end
      
      it "should return nil for an email address with no user" do
	nonexistent_user = User.authenticate("bar@foo.com", @attr[:password])
	nonexistent_user.should be_nil
      end
      
      it "should return the user on email/password match" do
	matching_user = User.authenticate(@attr[:email], @attr[:password])
	matching_user.should == @user
      end
    end
  end
  
  describe "admin attribute" do
      
      before(:each) do
	@user = User.create!(@attr)
      end
      
      it "should have an admin attribute" do
	@user.should respond_to(:admin)
      end
      
      it "should not be an admin by default" do
	@user.should_not be_admin
      end
      
      it "should be convertible to an admin" do
	@user.toggle!(:admin)
	@user.should be_admin
      end
  end
  
  describe "insults" do
    
    before(:each) do
      @user = User.create!(@attr)
      @user2 = Factory(:user)
      @inattr = { :insulted => @user, :insulter_id => @user2, :created_at => 1.day.ago }
      @in1 = Factory(:insult, @inattr)
      @in2 = Factory(:insult, @inattr.merge(:created_at => 1.hour.ago))
    end
    
    it "should have an add_insult! method" do
      @user.should respond_to(:add_insult!)
    end
    
    it "should have a reverse_insults method" do
      @user.should respond_to(:reverse_insults)
    end
    
    it "should have a insult_delete_power? attribute" do
      @user.should respond_to(:insult_delete_power?)
    end
    
    it "should have a feed attribute" do
      @user.should respond_to(:feed)
    end
    
    it "should have the insults in descending order" do
      @user.insults.should == [@in2, @in1]
    end
    
    it "should destroy insults associated with insulted on deletion" do
      @user.destroy
      [@in1, @in2].each do |insult|
	Insult.find_by_id(insult.id).should be_nil
      end
    end
    
    it "should destroy insults associated with insulter on deletion" do
      @new_insult = @user2.add_insult!(@user, "Content")
      @user2.destroy
      Insult.find_by_id(@new_insult.id).should be_nil
    end 
  end
  
  describe "comments" do
    
    before(:each) do
      @user = Factory(:user)
      @insulted = Factory(:user, :username => Factory.next(:username),
				 :email => Factory.next(:email))
      @insult = Factory(:insult, :insulter => @user, :insulted => @insulted)
      @attr = { :insult => @insult, :commenter => @user, :created_at => 1.day.ago }
      @comment1 = Factory(:comment, @attr)
      @comment2 = Factory(:comment, @attr.merge(:created_at => 1.hour.ago))
    end
    
    it "should destroy all comments associated with the user on deletion" do
      @user.destroy
      [@comment1, @comment2].each do |comment|
	Comment.find_by_id(comment.id).should be_nil
      end
    end
  end
  
  describe "relationships" do
    
    before(:each) do
      @user = User.create!(@attr)
      @followed = Factory(:user)
    end
    
    it "should have a relationships method" do
      @user.should respond_to(:relationships)
    end
    
    it "should have a following method" do
      @user.should respond_to(:following)
    end
    
    it "should have a following? method" do
      @user.should respond_to(:following?)
    end
    
    it "should have a follow! method" do
      @user.should respond_to(:follow!)
    end
    
    it "should follow another user" do
      @user.follow!(@followed)
      @user.should be_following(@followed)
    end
    
    it "should include the followed user in the following array" do
      @user.follow!(@followed)
      @user.following.should include(@followed)
    end
    
    it "should have an unfollow! method" do
      @user.should respond_to(:unfollow!)
    end
    
    it "should unfollow a user" do
      @user.follow!(@followed)
      @user.unfollow!(@followed)
      @user.should_not be_following(@followed)
    end
    
    it "should have a reverse_relationships method" do
      @user.should respond_to(:reverse_relationships)
    end
    
    it "should have a followers method" do
      @user.should respond_to(:followers)
    end
    
    it "should include the follower in the followers array" do
      @user.follow!(@followed)
      @followed.followers.should include(@user)
    end
    
    it "should destroy a user's relationships on deletion" do
      @relationship = @user.follow!(@followed)
      @user.destroy
      Relationship.find_by_id(@relationship.id).should be_nil
    end
    
    it "should destroy a user's reverse relationships on deletion" do
      @relationship = @user.follow!(@followed)
      @followed.destroy
      Relationship.find_by_id(@relationship.id).should be_nil
    end
  end
  
  describe "voting" do
    
    before(:each) do
      @user = User.create!(@attr)
      @other_user = Factory(:user)
    end
    
    describe "on" do
      
      it "should have a votes_for attribute" do
	@user.should respond_to(:votes_for)
      end
      
      it "should default to 0 votes_for" do
	@user.votes_for.should == 0
      end
      
      it "should have a votes_against attribute" do
	@user.should respond_to(:votes_against)
      end
      
      it "should default to 0 votes_against" do
	@user.votes_against.should == 0
      end
      
      it "should have a voted_by? attribute" do
	@user.should respond_to(:voted_by?)
      end
      
      it "should allow other users to vote for itself" do
	@other_user.vote_for(@user)
	@user.votes_for.should == 1
      end
      
      it "should allow other users to vote against itself" do
	@other_user.vote_against(@user)
	@user.votes_against.should == 1
      end
      
      it "should cap other user's votes for itself at one per user" do
	@other_user.vote_for(@user)
	lambda do
	  @other_user.vote_for(@user)
	end.should raise_exception
	@user.votes_for.should == 1
      end
      
      it "should cap other user's votes against itself at one per user" do
	@other_user.vote_against(@user)
	lambda do
	  @other_user.vote_against(@user)
	end.should raise_exception
	@user.votes_against.should == 1
      end
    end
    
    describe "for" do
      
      it "should have a vote_for method" do
	@user.should respond_to(:vote_for)
      end
      
      it "should have a vote_against method" do
	@user.should respond_to(:vote_against)
      end
      
      it "should have a voted_for? method" do
	@user.should respond_to(:voted_for?)
      end
      
      it "should have a voted_against? method" do
	@user.should respond_to(:voted_against?)
      end
      
      it "should have a vote_count method" do
	@user.should respond_to(:vote_count)
      end
      
      it "should have a clear_votes method" do
	@user.should respond_to(:clear_votes)
      end
      
      it "should have a voted_which_way? method" do
	@user.should respond_to(:voted_which_way?)
      end
    end
  end
  
  describe "answers" do
    
    before(:each) do
      @user = Factory(:user)
      @question = Factory(:daily_question)
      @q_attr = { :content => "Content", :daily_question_id => @question.id }
      @answer = @user.daily_answers.create!(@q_attr)
    end
    
    it "should respond to the daily_answers attribute" do
      @user.should respond_to(:daily_answers)
    end
    
    it "should destroy all daily_answers associated with the user on deletion" do
      @user.destroy
      DailyAnswer.find_by_id(@answer.id).should be_nil
    end
  end
  
  describe "answer marks" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    it "should have a marked_answers attribute" do
      @user.should respond_to(:marked_answers)
    end
    
    it "should have a already_marked_answer? method" do
      @user.should respond_to(:already_marked_answer?)
    end
    
    it "should return the right data for the already_answered? attribute" do
      question1 = Factory(:daily_question)
      question2 = Factory(:daily_question)
      other_user = Factory(:user, :username => Factory.next(:username),
				  :email => Factory.next(:email))
      answer1 = Factory(:daily_answer, :user => @user, :daily_question => question1)
      answer2 = Factory(:daily_answer, :user => other_user, :daily_question => question2)
      am1 = Factory(:answer_mark, :answer_id => answer1.id)
      am2 = Factory(:answer_mark, :answer_id => answer2.id)
      @user.already_marked_answer?(question1).should be_true
      @user.already_marked_answer?(question2).should_not be_true
    end
    
    it "should destroy marked answers on deletion" do
      question1 = Factory(:daily_question)
      question2 = Factory(:daily_question)
      answer1 = Factory(:daily_answer, :user => @user, :daily_question => question1)
      answer2 = Factory(:daily_answer, :user => @user, :daily_question => question2)
      am1 = Factory(:answer_mark, :answer_id => answer1.id)
      am2 = Factory(:answer_mark, :answer_id => answer2.id)
      @user.destroy
      [am1, am2].each do |am|
	AnswerMark.find_by_id(am.id).should be_nil
      end
    end
  end
end
