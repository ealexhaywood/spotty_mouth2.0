require 'spec_helper'

describe Insult do
  
  before(:each) do
    @insulter = Factory(:user)
    @insulted = Factory(:user, :username => Factory.next(:username),
			       :email => Factory.next(:email))
    @insult = @insulted.insults.build(:insulter_id => @insulter.id, 
                                      :content => "Content")
  end
  
  it "should create a new instance given valid attributes" do
    @insult.save!
  end
  
  describe "insulter methods" do
    
    before(:each) do
      @newinsult = @insulted.add_insult!(@insulter, "Content")
    end
    
    it "should have an insulter_id attribute" do
      @newinsult.should respond_to(:insulter_id)
    end
    
    it "should have the right insulter_id" do
      @newinsult.insulter_id.should == @insulter.id
    end
    
    it "should have an insulted_id attribute" do
      @newinsult.should respond_to(:insulted_id)
    end
    
    it "should have the right insulted_id" do
      @newinsult.insulted_id.should == @insulted.id
    end
    
    it "should have a votes_for attribute" do
      @newinsult.should respond_to(:votes_for)
    end
    
    it "should default to 0 votes_for" do
      @newinsult.votes_for.should == 0
    end
    
    it "should have a votes_against attribute" do
      @newinsult.should respond_to(:votes_against)
    end
    
    it "should default to 0 votes_against" do
      @newinsult.votes_against.should == 0
    end
    
    it "should have a voted_by? attribute" do
      @newinsult.should respond_to(:voted_by?)
    end
  end
  
  describe "attribute strip" do
    
    it "should remove leading and trailing whitespace from an insult" do
      @insult.content = "   Content   "
      @insult.save!
      @insult.reload
      @insult.content.should == "Content"
    end
  end
  
  describe "validations" do
    
    it "should require content" do
      @insult.content = nil
      @insult.should_not be_valid
    end
    
    it "should reject content that is over 255 characters" do
      @insult.content = "a" * 256
      @insult.should_not be_valid
    end
    
    it "should require an insulter_id" do
      @insult.insulter_id = nil
      @insult.should_not be_valid
    end
    
    it "should require an insulted_id" do
      @insult.insulted_id = nil
      @insult.should_not be_valid
    end
  end
  
  describe "comments" do
    
    before(:each) do
      @insult.save!
      @attr = { :insult => @insult, :commenter => @insulter, :created_at => 1.day.ago }
      @comment1 = Factory(:comment, @attr)
      @comment2 = Factory(:comment, @attr.merge(:created_at => 1.hour.ago))
    end
    
    it "should destroy all comments associated with insult on deletion" do
      @insult.destroy
      [@comment1, @comment2].each do |comment|
	Comment.find_by_id(comment.id).should be_nil
      end
    end
  end
end
