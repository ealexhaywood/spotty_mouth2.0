require 'spec_helper'

describe DailyQuestionsController do
render_views

  describe "GET 'index'" do
    
    before(:each) do
      @question = Factory(:daily_question)
    end
    
    it "should be successful" do
      get :index
      response.should be_success
    end
    
    it "should show the latest daily_question" do
      question2 = Factory(:daily_question, :content => "This is the 2nd Q?")
      get :index
      response.should have_selector("div", :class => "daily_question",
					   :content => question2.content)
      response.should_not have_selector("div", :class => "daily_question",
					       :content => @question.content)
    end
    
    it "should not have a link to a new question" do
      get :index
      response.should_not have_selector("a", :content => "Add new question",
					 :href => new_daily_question_path)
    end
    
    it "should have a login/register prompt" do
      get :index 
      response.should have_selector("a", :content => "login",
					 :href => signin_path)
      response.should have_selector("a", :content => "register",
					 :href => signup_path)
      response.should have_selector("p.login_prompt", :content => "comment")
    end
    
    it "should not have a daily_answer_post form" do
      get :index
      response.should_not have_selector("form")
    end
    
    it "should paginate answers" do
      @user = Factory(:user)
      @answers = []
      31.times do
	@answers << Factory(:daily_answer, :user => @user, :daily_question => @question)
      end
      get :index
      response.should have_selector("div.pagination")
      response.should have_selector("span.disabled", :content => "Previous")
      response.should have_selector("a", :content => "2")
      response.should have_selector("a", :content => "Next")
    end
    
    it "should not have any 'Mark as Answer' or 'Unmark' links" do
      user = Factory(:user)
      answer1 = Factory(:daily_answer, :user => user, :daily_question => @question)
      am = Factory(:answer_mark, :answer_id => answer1.id)
      get :index
      response.should_not have_selector("a", :content => "Mark as Answer")
      response.should_not have_selector("a", :content => "Unmark")
    end
    
    it "should highlight the marked answerss" do
      user = Factory(:user)
      answer1 = Factory(:daily_answer, :user => user, :daily_question => @question)
      am = Factory(:answer_mark, :answer_id => answer1.id)
      get :index
      response.should have_selector("div#answer_#{answer1.id}", :class => "object_wrapper marked_answer")
    end
    
    it "should have a link to the archive" do
      get :index
      response.should have_selector("a", :href => daily_questions_archive_path)
    end
    
    describe "when signed in" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user))
      end
      
      it "should not have a link to a new question" do
	get :index
	response.should_not have_selector("a", :content => "Add new question",
					  :href => new_daily_question_path)
      end
      
      it "should not have a login/register prompt" do
	get :index
	response.should_not have_selector("a", :content => "login",
					  :href => signin_path)
	response.should_not have_selector("a", :content => "register",
					  :href => signup_path)
	response.should_not have_selector("p.login_prompt", :content => "burn")
      end
      
      it "should have a daily_answer_post form" do
	get :index
	response.should have_selector("form")
      end
      
      it "should show delete links for the user's own answers but not for others'" do
	@other_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	answer1 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	answer2 = Factory(:daily_answer, :user => @other_user, :daily_question => @question)
	get :index
	response.should have_selector("a", :content => "Delete",
					   :"data-method" => "delete",
					   :href => daily_answer_path(answer1))
	response.should_not have_selector("a", :content => "Delete",
	                                  :"data-method" => "delete",
	                                  :href => daily_answer_path(answer2))
      end
      
      describe "without a marked answer" do
	
	it "should show 'Mark as Answer' links for the user's own answers but not for others" do
	  @other_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	answer1 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	answer2 = Factory(:daily_answer, :user => @other_user, :daily_question => @question)
	get :index
	response.should have_selector("a", :content => "Mark as Answer",
					   :href => answer_marks_path(:id => answer1.id))
	response.should_not have_selector("a", :content => "Mark as Answer",
					   :href => answer_marks_path(:id => answer2.id))
	end
      end
      
      describe "with a marked answer" do
	
	it "should show an 'Unmark' link where the user's marked answer is" do
	  answer1 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	  am = Factory(:answer_mark, :answer_id => answer1.id)
	  get :index
	  response.should have_selector("a", :content => "Unmark",
					     :"data-method" => "delete",
					     :href => answer_mark_path(am.id))
	end
	
	it "should not show any 'Mark as Answer' links" do
	  answer1 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	  answer2 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	  am = Factory(:answer_mark, :answer_id => answer1.id)
	  get :index
	  response.should_not have_selector("a", :content => "Mark as Answer")
	end
      end
    end
    
    describe "as an admin" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user, :admin => true))
      end
      
      it "should have a link to a new question" do
	get :index
	response.should have_selector("a", :content => "Add new question",
					  :href => new_daily_question_path)
      end
      
      it "should show delete links for all answers" do
	@other_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	answer1 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	answer2 = Factory(:daily_answer, :user => @other_user, :daily_question => @question)
	get :index
	response.should have_selector("a", :content => "Delete",
					   :"data-method" => "delete",
					   :href => daily_answer_path(answer1))
	response.should have_selector("a", :content => "Delete",
	                                  :"data-method" => "delete",
	                                  :href => daily_answer_path(answer2))
      end
    end
  end
  
  describe "GET 'archive'" do
    
    before(:each) do
      @dq1 = Factory(:daily_question)
      30.times do
	Factory(:daily_question)
      end
      @dq2 = Factory(:daily_question)
    end
    
    it "should show paginate results" do
      get :archive
      response.should have_selector("div.pagination")
      response.should have_selector("span.disabled", :content => "Previous")
      response.should have_selector("a", :content => "2")
      response.should have_selector("a", :content => "Next")
    end
    
    it "should have links to the rendered daily_question show pages" do
      get :archive
      response.should have_selector("a", :href => daily_question_path(@dq2))
      response.should_not have_selector("a", :href => daily_question_path(@dq1))
    end
    
    it "should only show entries in selected timeframe" do
      question1 = Factory(:daily_question, :created_at => "2012-02-17 00:00:00")
      question2 = Factory(:daily_question, :created_at => "2011-02-17 00:00:00")
      get :archive, :timeframe => "2012-02-17 00:00:00"
      response.should have_selector("a", :href => daily_question_path(question1))
      response.should_not have_selector("a", :content => daily_question_path(question2))
    end
  end                             

  describe "GET 'show'" do
    
    before(:each) do
      @user = Factory(:user)
      @question = Factory(:daily_question)
      @answer = Factory(:daily_answer, :user => @user, :daily_question => @question)
    end
    
    it "should be successful" do
      get :show, :id => @question
      response.should be_success
    end
    
    it "should not have a link to a new question" do
      get :show, :id => @question
      response.should_not have_selector("a", :content => "Add new question",
					 :href => new_daily_question_path)
    end
    
    it "should have a login/register prompt" do
      get :show, :id => @question 
      response.should have_selector("a", :content => "login",
					 :href => signin_path)
      response.should have_selector("a", :content => "register",
					 :href => signup_path)
      response.should have_selector("p.login_prompt", :content => "comment")
    end
    
    it "should not have a daily_answer_post form" do
      get :show, :id => @question
      response.should_not have_selector("form")
    end
    
    it "should paginate answers" do
      @answers = [@answer]
      31.times do
	@answers << Factory(:daily_answer, :user => @user, :daily_question => @question)
      end
      get :show, :id => @question
      response.should have_selector("div.pagination")
      response.should have_selector("span.disabled", :content => "Previous")
      response.should have_selector("a", :content => "2")
      response.should have_selector("a", :content => "Next")
    end
    
    it "should have a link to the archive" do
      get :show, :id => @question
      response.should have_selector("a", :href => daily_questions_archive_path)
    end
    
    describe "when signed in" do
      
      before(:each) do
	test_sign_in(@user)
      end
      
      it "should not have a link to a new question" do
	get :show, :id => @question
	response.should_not have_selector("a", :content => "Add new question",
					  :href => new_daily_question_path)
      end
      
      it "should not have a login/register prompt" do
	get :show, :id => @question
	response.should_not have_selector("a", :content => "login",
					  :href => signin_path)
	response.should_not have_selector("a", :content => "register",
					  :href => signup_path)
	response.should_not have_selector("p.login_prompt", :content => "burn")
      end
      
      it "should have a daily_answer_post form" do
	get :show, :id => @question
	response.should have_selector("form")
      end
      
      it "should show delete links for the user's own answers but not for others'" do
	@other_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	answer1 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	answer2 = Factory(:daily_answer, :user => @other_user, :daily_question => @question)
	get :show, :id => @question
	response.should have_selector("a", :content => "Delete",
					   :"data-method" => "delete",
					   :href => daily_answer_path(answer1))
	response.should_not have_selector("a", :content => "Delete",
	                                  :"data-method" => "delete",
	                                  :href => daily_answer_path(answer2))
      end
      
      describe "without a marked answer" do
	
	it "should show 'Mark as Answer' links for the user's own answers but not for others" do
	  @other_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	answer1 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	answer2 = Factory(:daily_answer, :user => @other_user, :daily_question => @question)
	get :index
	response.should have_selector("a", :content => "Mark as Answer",
					   :href => answer_marks_path(:id => answer1.id))
	response.should_not have_selector("a", :content => "Mark as Answer",
					   :href => answer_marks_path(:id => answer2.id))
	end
      end
      
      describe "with a marked answer" do
	
	it "should show an 'Unmark' link where the user's marked answer is" do
	  answer1 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	  am = Factory(:answer_mark, :answer_id => answer1.id)
	  get :index
	  response.should have_selector("a", :content => "Unmark",
					     :"data-method" => "delete",
					     :href => answer_mark_path(am.id))
	end
	
	it "should not show any 'Mark as Answer' links" do
	  answer1 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	  answer2 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	  am = Factory(:answer_mark, :answer_id => answer1.id)
	  get :index
	  response.should_not have_selector("a", :content => "Mark as Answer")
	end
      end
    end
    
    describe "as an admin" do
      
      before(:each) do
	@user.toggle!(:admin)
	test_sign_in(@user)
      end
      
      it "should have a link to a new question" do
	get :show, :id => @question
	response.should have_selector("a", :content => "Add new question",
					  :href => new_daily_question_path)
      end
      
      it "should show delete links for all answers" do
	@other_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	answer1 = Factory(:daily_answer, :user => @user, :daily_question => @question)
	answer2 = Factory(:daily_answer, :user => @other_user, :daily_question => @question)
	get :show, :id => @question
	response.should have_selector("a", :content => "Delete",
					   :"data-method" => "delete",
					   :href => daily_answer_path(answer1))
	response.should have_selector("a", :content => "Delete",
	                                  :"data-method" => "delete",
	                                  :href => daily_answer_path(answer2))
      end
    end
  end

  describe "GET 'new'" do
    
    describe "access control" do
      
      it "should redirect non-registered users to root" do
	get :new
	response.should redirect_to root_path
      end
      
      it "should redirect non-admins to root" do
	user = test_sign_in(Factory(:user))
	get :new
	response.should redirect_to root_path
      end
      
      it "should allow access to admins" do
	user = test_sign_in(Factory(:user, :admin => true))
	get :new
	response.should be_success
      end
    end
  end

  describe "POST 'create'" do
    
    describe "access control" do
      
      it "should redirect non-registered users to root" do
	post :create
	response.should redirect_to root_path
      end
      
      it "should redirect non-admins to root" do
	user = test_sign_in(Factory(:user))
	post :create
	response.should redirect_to root_path
      end
    end
    
    describe "failure" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user, :admin => true))
	@attr = Factory.attributes_for(:daily_question)
      end
      
      it "should render the 'new' page with errors" do
	post :create, :daily_question => @attr.merge(:content => "")
	response.should render_template 'daily_questions/new'
	flash[:error].should_not be_nil
      end
      
      it "should not change the DailyQuestions count" do
	lambda do
	  post :create, :daily_question => @attr.merge(:content => "")
	end.should_not change(DailyQuestion, :count)
      end
    end
    
    describe "success" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user, :admin => true))
	@attr = Factory.attributes_for(:daily_question)
      end
      
      it "should redirect to the questions show page with a success message" do
	post :create, :daily_question => @attr
	response.should redirect_to daily_question_path(assigns(:daily_question))
	flash[:success].should_not be_nil
      end
      
      it "should change the DailyQuestions count" do
	lambda do
	  post :create, :daily_question => @attr
	end.should change(DailyQuestion, :count).by(1)
      end
    end
  end

  describe "DELETE 'destroy'" do
    
    describe "access control" do
      
      it "should redirect non-registered users to root" do
	post :create
	response.should redirect_to root_path
      end
      
      it "should redirect non-admins to root" do
	user = test_sign_in(Factory(:user))
	post :create
	response.should redirect_to root_path
      end
    end
    
    it "should remove the question" do
      question = Factory(:daily_question)
      user = test_sign_in(Factory(:user, :admin => true))
      lambda do
	delete :destroy, :id => question
      end.should change(DailyQuestion, :count).by(-1)
      DailyAnswer.find_by_id(question.id).should be_nil
    end
    
    it "should redirect to the daily_questions index" do
      question = Factory(:daily_question)
      user = test_sign_in(Factory(:user, :admin => true))
      delete :destroy, :id => question
      response.should redirect_to daily_questions_path
    end
  end
end
