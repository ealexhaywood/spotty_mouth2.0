require 'spec_helper'

describe DailyAnswer do
  
  before(:each) do
    @question = Factory(:daily_question)
    @user = Factory(:user)
    @attr = { :content => "Foo bar", :daily_question_id => @question.id,
              :user_id => @user.id}
  end
  
  it "should save an instance given valid attributes" do
    DailyAnswer.create!(@attr)
  end
  
  it "should be ordered by the created_by column" do
    da1 = DailyAnswer.create!(@attr)
    user2 = Factory(:user, :username => Factory.next(:username),
			   :email => Factory.next(:email))
    new_attr = { :content => "Foo baz", :daily_question_id => @question.id,
			  :user_id => user2.id }
    da2 = DailyAnswer.create!(@attr)
    da1.update_attribute(:content, "Foo bazoo")
    da_all = DailyAnswer.all
    da_all[0].should == da1
    da_all[1].should == da2
  end
  
  describe "validations" do
    
    it "should require content" do
      answer = DailyAnswer.new(@attr.merge(:content => ""))
      answer.should_not be_valid
    end
    
    it "should require a daily_question_id" do
      answer = DailyAnswer.new(@attr.merge(:daily_question_id => ""))
      answer.should_not be_valid
    end
    
    it "should require a user_id" do
      answer = DailyAnswer.new(@attr.merge(:user_id => ""))
      answer.should_not be_valid
    end
    
    it "should remove leading and trailing whitespaces from content" do
      answer = DailyAnswer.new(@attr.merge(:content => "  Whitespaces  "))
      answer.save
      answer.content.should == "Whitespaces"
    end
    
    it "should reject content that is too long" do
      answer = DailyAnswer.new(@attr.merge(:content => "a"*256))
      answer.should_not be_valid
    end
  end
end
