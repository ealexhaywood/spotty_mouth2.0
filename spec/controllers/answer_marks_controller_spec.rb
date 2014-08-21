require 'spec_helper'

describe AnswerMarksController do

  describe "POST 'create'" do
    
    before(:each) do
      @user = Factory(:user)
      @question = Factory(:daily_question)
      @answer = Factory(:daily_answer, :user => @user, :daily_question => @question)
    end
    
    describe "access control" do
      
      it "should require the user to be authenticated" do
	post :create, :id => @answer.id
	response.should redirect_to signin_path
      end
    
      it "should redirect users who did not create the answer to root" do
	@other_user = test_sign_in(Factory(:user, :username => Factory.next(:username),
						  :email => Factory.next(:email)))
	post :create, :id => @answer.id
	response.should redirect_to root_path
      end
    end
    
    describe "failure" do
      
      before(:each) do
	test_sign_in(@user)
	@am = Factory(:answer_mark, :answer_id => @answer.id)
      end
      
      it "should not create a new AnswerMark" do
	lambda do
	  post :create, :id => @answer.id
	end.should_not change(AnswerMark, :count)
      end
      
      it "should not create a new AnswerMark via AJAX" do
	lambda do
	  xhr :post, :create, :id => @answer.id
	end.should_not change(AnswerMark, :count)
      end
      
      it "should redirect to the daily_question page with an error message" do
	post :create, :id => @answer.id
	flash[:error].should =~ /Setting could not be saved./
	response.should redirect_to(daily_question_path(@answer.daily_question))
      end
    end
    
    describe "success" do
      
      before(:each) do 
	test_sign_in(@user)
      end
      
      it "should add a new answer mark" do
	lambda do
	  post :create, :id => @answer.id
	end.should change(AnswerMark, :count).by(1)
      end
      
      it "should add a new answer mark via AJAX" do
	lambda do
	  xhr :post, :create, :id => @answer.id
	end.should change(AnswerMark, :count).by(1)
      end
    end
  end

  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
      @question = Factory(:daily_question)
      @answer = Factory(:daily_answer, :user => @user, :daily_question => @question)
      @answer_mark = Factory(:answer_mark, :answer_id => @answer.id)
    end
    
    describe "access control" do
      
      it "should require users to be authenticated" do
	delete :destroy, :id => @answer_mark
	response.should redirect_to signin_path
      end
      
      it "should redirect user's who did not create the answer to root" do
	@other_user = test_sign_in(Factory(:user, :username => Factory.next(:username),
						  :email => Factory.next(:email)))
	delete :destroy, :id => @answer_mark
	response.should redirect_to root_path
      end
    end
    
    describe "success" do
      
      before(:each) do
	test_sign_in(@user)
      end
      
      it "should delete the answer mark" do
	lambda do
	  delete :destroy, :id => @answer_mark
	end.should change(AnswerMark, :count).by(-1)
      end
      
      it "should redirect user's to the deleted answer mark's question" do
	delete :destroy, :id => @answer_mark
	response.should redirect_to(daily_question_path(@question.id))
      end
      
      it "should delete the answer mark via AJAX" do
	lambda do
	  xhr :delete, :destroy, :id => @answer_mark
	end.should change(AnswerMark, :count).by(-1)
      end
    end
  end
end
