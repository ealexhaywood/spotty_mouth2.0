require 'spec_helper'

describe AnswerMark do
  
  before(:each) do
    @user = Factory(:user)
    @question = Factory(:daily_question)
    @answer = Factory(:daily_answer, :user => @user, :daily_question => @question)
    @attr = { :answer_id => @answer.id }
  end
  
  it "should save a new instance given valid attributes" do
    AnswerMark.create!(@attr)
  end
  
  it "should have the right answer_id" do
    am = AnswerMark.create!(@attr)
    am.answer_id.should == @answer.id
  end
  
  it "should have the right user_id by assocation" do
    am = AnswerMark.create!(@attr)
    am.user_id.should == @answer.user.id
  end
  
  it "should have the right question_id by assocation" do
    am = AnswerMark.create!(@attr)
    am.question_id.should == @question.id
  end
  
  describe "assocations" do
    
    it "should have the correct answer property" do
      am = AnswerMark.create!(@attr)
      am.answer.should == @answer
    end
    
    it "should set the foreign key of the daily_answer" do
      am = AnswerMark.create!(@attr)
      @answer.reload
      @answer.answer_mark_id.should == am.id
    end
    
    it "should have the correct question property" do
      am = AnswerMark.create!(@attr)
      am.question.should == @question
    end
    
    it "should have the right user property" do
      am = AnswerMark.create!(@attr)
      am.user.should == @user
    end
  end
  
  describe "validations" do
    
    it "should require an answer_id" do
      answer = AnswerMark.new(@attr.merge(:answer_id => ""))
      answer.should_not be_valid
    end
    
    it "should reject duplicate user_id/question_id pairs" do
      AnswerMark.create!(@attr)
      @answer2 = Factory(:daily_answer, :user => @user, :daily_question => @question)
      am = AnswerMark.new(@attr.merge(:answer_id => @answer2.id))
      am.should_not be_valid
    end
    
    it "should reject duplicate answer_ids" do
      AnswerMark.create!(@attr)
      test_q = Factory(:daily_question)
      am = AnswerMark.new(@attr.merge(:question_id => test_q.id))
      am.should_not be_valid
    end
  end
  
  describe "deletion" do
    
    it "should nullify the associated daily_answers' foreign key" do
      am = AnswerMark.create!(@attr)
      @answer.reload
      @answer.answer_mark_id.should == am.id
      am.destroy
      @answer.reload
      @answer.answer_mark_id.should == nil
    end
  end    
end
