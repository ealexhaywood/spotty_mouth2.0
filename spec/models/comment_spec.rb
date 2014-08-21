require 'spec_helper'

describe Comment do
  
  before(:each) do
    @user = Factory(:user)
    @insulted = Factory(:user, :username => Factory.next(:username),
			       :email => Factory.next(:email))
    @insult = Factory(:insult, :insulter => @user, :insulted => @insulted)
  end
  
  it "should create a new instance given valid attributes" do
    @insult.comments.build(:commenter_id => @user, :content => "Foo bar")
    @insult.save!
  end
  
  describe "comment methods" do
    
    before(:each) do
      @comment = @insult.comments.create!(:commenter_id => @user.id, :content => "Foo bar")
    end
    
    it "should have a commenter_id attribute" do
      @comment.should respond_to(:commenter_id)
    end
    
    it "should have the right commenter_id" do
      @comment.commenter_id.should == @user.id
    end
    
    it "should have a content attribute" do
      @comment.should respond_to(:content)
    end
    
    it "should have the right content" do
      @comment.content.should == "Foo bar"
    end
  end
  
  describe "attribute strip" do
    
    before(:each) do
      @comment = @insult.comments.create!(:commenter_id => @user.id, :content => "   Foo bar   ")
    end
    
    it "should remove leading and trailing whitespace from a comment" do
      @comment.reload
      @comment.content.should == "Foo bar"
    end
  end
  
  describe "validations" do
    
    before(:each) do
      @attr = { :commenter_id => @user.id, :content => "Foo bar" }
    end
    
    it "should require a commenter_id" do
      comment = @insult.comments.build(@attr.merge(:commenter_id => ""))
      comment.should_not be_valid
    end
    
    it "should require content after whitespace strip" do
      comment = @insult.comments.build(@attr.merge(:content => "        "))
      comment.should_not be_valid
    end
    
    it "should reject content that is too long" do
      comment = @insult.comments.build(@attr.merge(:content => "a" * 256))
      comment.should_not be_valid
    end
      
    it "should require an insult_id" do
      comment = @user.comments.build(:content => "Foo bar")
      comment.should_not be_valid
    end
    
    it "should protect the commenter_id attribute" do
      @comment = @insult.comments.create!(@attr)
      lambda do
	@comment.update_attribute(:commenter_id, "134590872345")
      end.should raise_exception
      @comment.reload
      @comment.commenter_id.should == @user.id
      @comment.commenter_id.should_not == "134590872345"
    end
    
    it "should protect the insult_id attribute" do
      @comment = @insult.comments.create!(@attr)
      lambda do
	@comment.update_attribute(:insult_id, "134590872345")
      end.should raise_exception
      @comment.reload
      @comment.insult_id.should == @insult.id
      @comment.insult_id.should_not == "134590872345"
    end
  end      
end
