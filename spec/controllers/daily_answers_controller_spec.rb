require 'spec_helper'

describe DailyAnswersController do
  render_views

  describe "POST 'create'" do
    
    before(:each) do
      @question = Factory(:daily_question)
      @attr = Factory.attributes_for(:daily_answer)
    end
    
    describe "access control" do
      
      it "should redirect non-authenticated users to signin path" do
	post :create, :daily_question_id => @question.id, :daily_answer => @attr
	response.should redirect_to signin_path
      end
      
      it "should not change the DailyAnswer count" do
	lambda do
	  post :create, :daily_question_id => @question.id, :daily_answer => @attr
	end.should_not change(DailyAnswer, :count)
      end
    end
    
    describe "failure" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user))
      end
      
      it "should not create a new daily_answer" do
	lambda do
	  post :create, :daily_question_id => @question.id, :daily_answer => ""
	end.should_not change(DailyAnswer, :count)
      end
      
      it "should show a flash error message and render the 'daily_question/show' form" do
	post :create, :daily_question_id => @question.id, :daily_answer => ""
	response.should render_template 'daily_questions/show'
	assigns[:daily_question].id.should == @question.id
	flash[:error].should_not be_nil
      end
    end
    
    describe "success" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user))
      end
      
      it "should create a new daily_answer" do
	lambda do
	  post :create, :daily_question_id => @question.id, :daily_answer => @attr
	end.should change(DailyAnswer, :count).by(1)
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @question = Factory(:daily_question)
      @user = Factory(:user)
      @answer = Factory(:daily_answer, :daily_question_id => @question.id,
	                  :user_id => @user.id)
    end
      
    describe "access control" do
      
      it "should redirect non-authenticated users to signin path" do
	delete :destroy, :id => @answer
	response.should redirect_to signin_path
      end
      
      it "should redirect users who were not the answerer to root path" do
	other_user = Factory(:user, :username => Factory.next(:username),
				    :email => Factory.next(:email))
	test_sign_in(other_user)
	delete :destroy, :id => @answer
	response.should redirect_to root_path
      end
    end
    
    describe "for users deleting their own answers" do
      
      before(:each) do
	test_sign_in(@user)
      end
      
      it "should delete the answer" do
	lambda do
	  delete :destroy, :id => @answer
	end.should change(DailyAnswer, :count).by(-1)
      end
      
      it "should redirect to the corresponding daily_question show path" do
	delete :destroy, :id => @answer
	response.should redirect_to(daily_question_path(@question))
      end
    end
    
    describe "for admin users" do
      
      before(:each) do
	@admin = test_sign_in(Factory(:user, :username => Factory.next(:username),
				      :email => Factory.next(:email),
	                              :admin => true))
      end
      
      it "should delete the answer" do
	lambda do
	  delete :destroy, :id => @answer
	end.should change(DailyAnswer, :count).by(-1)
      end
      
      it "should redirect to the corresponding daily_question show path" do
	delete :destroy, :id => @answer
	response.should redirect_to(daily_question_path(@question))
      end
    end	                    
  end
end
