require 'spec_helper'

describe DailyQuestion do
  
  before(:each) do 
    @attr = { :content => "This is a question" }
  end
  
  it "should save an instance given valid attributes" do
    DailyQuestion.create!(@attr)
  end
  
  it "should be ordered DESC by the created_by column" do
    dq1 = DailyQuestion.create!(@attr)
    dq2 = DailyQuestion.create!(@attr)
    dq1.update_attribute(:content, "Foo bazoo")
    dq_all = DailyQuestion.all
    dq_all[0].should == dq2
    dq_all[1].should == dq1
  end
  
  it "should paginate per every 31 results" do
    DailyQuestion.per_page.should == 31
  end
  
  describe "validations" do
    
    it "should reject blank content" do
      question = DailyQuestion.new(@attr.merge(:content => ""))
      question.should_not be_valid
    end
    
    it "should strip leading and trailing whitespace from content" do
      question = DailyQuestion.new(@attr.merge(:content => "  Whitespaces  "))
      question.save
      question.content.should == "Whitespaces"
    end
    
    it "should reject content that is too long" do
      question = DailyQuestion.new(@attr.merge(:content => "a"*256))
      question.should_not be_valid
    end
  end
  
  describe "daily_answers" do
    
    before(:each) do
      @user = Factory(:user)
      @question = Factory(:daily_question)
      @q_attr = { :content => "Content", :daily_question_id => @question.id }
      @answer = @user.daily_answers.create!(@q_attr)
    end
    
    it "should destroy all daily_answers associated with the question on deletion" do
      @question.destroy
      DailyAnswer.find_by_id(@answer.id).should be_nil
    end
  end
  
  describe "marked_answers" do
    
    before(:each) do
      @question = Factory(:daily_question)
    end
    
    it "should respond to the marked_answers attribute" do
      @question.should respond_to(:marked_answers)
    end
    
    it "should destroy marked_answers on deletion" do
      user1 = Factory(:user)
      user2 = Factory(:user, :username => Factory.next(:username),
			     :email => Factory.next(:email))
      answer1 = Factory(:daily_answer, :user => user1, :daily_question => @question)
      answer2 = Factory(:daily_answer, :user => user2, :daily_question => @question)
      am1 = Factory(:answer_mark, :answer_id => answer1.id)
      am2 = Factory(:answer_mark, :answer_id => answer2.id)
      @question.destroy
      [am1, am2].each do |am|
	AnswerMark.find_by_id(am.id).should be_nil
      end
    end
  end
end
