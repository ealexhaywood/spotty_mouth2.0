require 'spec_helper'

describe UsersController do
  include CarrierWave::Test::Matchers
  render_views
  
  describe "GET 'show'" do
     before(:each) do
      @user = Factory(:user)
     end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end
    
    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.username)
    end
    
    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.username)
    end
    
    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "avatar")
    end
      
    it "should not show the delete links" do
      get :show, :id => @user
      response.should_not have_selector("a", :"data-method" => "delete",
					     :href => "/users/#{@user.id}",
					     :content => "delete")
    end
    
    it "should not show the user vote links" do
      get :show, :id => @user
      response.should_not have_selector("a", :"data-method" => "post",
					     :href => vote_up_user_path(@user))
    end
    
    it "should show the user's insults" do
      @user2 = Factory(:user, :username => Factory.next(:username),
			      :email => Factory.next(:email))
      @inattr = { :insulted => @user, :insulter => @user2, :created_at => 1.day.ago }
      in1 = Factory(:insult, @inattr)
      in2 = Factory(:insult, @inattr.merge(:created_at => 1.hour.ago))
      get :show, :id => @user
      response.should have_selector("div", :content => in1.content)
      response.should have_selector("div", :content => in2.content)
    end
    
    it "should paginate the user's insults" do
      @user2 = Factory(:user, :username => Factory.next(:username),
			      :email => Factory.next(:email))
      @insults = []
      31.times do
	@insults << Factory(:insult, :insulter => @user2, :insulted => @user)
      end
      get :show, :id => @user
      response.should have_selector("div.pagination")
      response.should have_selector("span.disabled", :content => "Previous")
      response.should have_selector("a", :content => "2")
      response.should have_selector("a", :content => "Next")
    end
    
    it "should not show the insult vote links" do
      @user2 = Factory(:user, :username => Factory.next(:username),
			      :email => Factory.next(:email))
      @inattr = { :insulted => @user, :insulter => @user2, :created_at => 1.day.ago }
      @insult = Factory(:insult, @inattr)
      get :show, :id => @user
      response.should_not have_selector("a", :"data-method" => "post",
					     :href => vote_up_insult_path(@insult.id))
    end
    
    it "should render the 'user_number_links' partial" do
      get :show, :id => @user
      response.should render_template('shared/_user_number_links')
    end
    
    it "should show the link to the insult comments" do
      @user2 = Factory(:user, :username => Factory.next(:username),
			      :email => Factory.next(:email))
      @inattr = { :insulted => @user, :insulter => @user2 }
      @insult = Factory(:insult, @inattr)
      get :show, :id => @user
      response.should have_selector("a", :content => "Comments(0)",
					 :href => insult_comments_path(@insult))
    end
    
    it "should have a prompt to signin or register to leave an insult" do
      get :show, :id => @user
      response.should have_selector("a", :content => "login",
					 :href => signin_path)
      response.should have_selector("a", :content => "register",
					 :href => signup_path)
      response.should have_selector("p.login_prompt", :content => "burn")
    end
    
    it "should show the user's marked answer and a link to the daily question" do
      question = Factory(:daily_question)
      answer1 = Factory(:daily_answer, :user => @user, :daily_question => question)
      am = Factory(:answer_mark, :answer_id => answer1.id)
      get :show, :id => @user
      response.should have_selector("div", :content => am.answer.content)
      response.should have_selector("a", :href => daily_question_path(question))
    end
    
    it "should default to 'No Answer Yet' if user has not answered daily question" do
      question = Factory(:daily_question)
      get :show, :id => @user
      response.should have_selector("p", :content => "No Answer Yet")
    end      
    
    describe "for signed in users" do
      
      before(:each) do
	test_sign_in(@user)
      end
      
      it "should show the user vote links" do
	get :show, :id => @user
	response.should have_selector("a", :"data-method" => "post",
					   :href => vote_up_user_path(@user))
      end
      
      it "should show the insult vote links" do
	@user2 = Factory(:user, :username => Factory.next(:username),
			        :email => Factory.next(:email))
	@inattr = { :insulted => @user, :insulter => @user2, :created_at => 1.day.ago }
	@insult = Factory(:insult, @inattr)
	get :show, :id => @user
	response.should have_selector("a", :"data-method" => "post",
					   :href => vote_up_insult_path(@insult.id))
      end
      
      it "should not have a prompt to signin or register to leave an insult" do
	get :show, :id => @user
	response.should_not have_selector("a", :content => "login",
					  :href => signin_path)
	response.should_not have_selector("a", :content => "register",
					  :href => signup_path)
	response.should_not have_selector("p.login_prompt", :content => "burn")
      end
    end
    
    describe "for signed in users viewing themselves" do
    
      before(:each) do
	test_sign_in(@user)
	get :show, :id => @user
      end
      
      it "should have a link to the user edit page" do
	response.should have_selector("a", :href => edit_user_path)
      end
      
      it "should not show the user delete link" do
	get :show, :id => @user
	response.should_not have_selector("a", :"data-method" => "delete",
					  :href => "/users/#{@user.id}",
					  :content => "Delete")
      end
      
      it "should not have a link to the 'beef_with' page" do
	get :show, :id => @user
	response.should_not have_selector("a", :href => beef_with_path(@user))
      end
      
      it "should show insult delete links" do
	@other_user = Factory(:user, :email => Factory.next(:email),
				     :username => Factory.next(:username))
	@insult = @user.add_insult!(@other_user, "Content")
	get :show, :id => @user
	response.should have_selector("a", :href => insult_path(@insult),
					   :"data-method" => "delete",
					   :content => "Delete")
      end
    end
    
    describe "for signed in users viewing others" do
      
      before(:each) do
	test_sign_in(@user)
	@other_user = Factory(:user, :email => Factory.next(:email),
				     :username => Factory.next(:username))
	get :show, :id => @other_user
      end
    
      it "should not have a link to the user edit page" do
	response.should_not have_selector("a", :href => edit_user_path)
      end
      
      it "should have a link to the 'beef_with' page" do
	get :show, :id => @other_user
	response.should have_selector("a", :href => beef_with_path(@other_user))
      end
      
      it "should not show the user delete link" do
	response.should_not have_selector("a", :"data-method" => "delete",
					  :href => "/users/#{@other_user.id}",
					  :content => "Delete")
      end
      
      it "should not show insult delete links" do
	@insulted = Factory(:user, :username => Factory.next(:username),
				   :email => Factory.next(:email))
	@insult = @insulted.add_insult!(@other_user, "Content")
	get :show, :id => @insulted
	response.should_not have_selector("a", :href => insult_path(@insult),
					   :"data-method" => "delete",
					   :content => "Delete")
      end
    end
    
    describe "for admin users" do
      
      before(:each) do
	@other_user = Factory(:user, :email => Factory.next(:email),
				     :username => Factory.next(:username))
	@admin = Factory(:user, :email => Factory.next(:email),
				     :username => Factory.next(:username),
				      :admin => true)
	test_sign_in(@admin)
      end
      
      it "should show the user delete link" do
	get :show, :id => @other_user
	response.should have_selector("a", :"data-method" => "delete",
					  :href => "/users/#{@other_user.id}",
					  :content => "Delete")
      end
      
      it "should show the insult delete links" do
	@insulted = Factory(:user, :username => Factory.next(:username),
				   :email => Factory.next(:email))
	@insult = @insulted.add_insult!(@other_user, "Content")
	get :show, :id => @insulted
	response.should have_selector("a", :href => insult_path(@insult),
					   :"data-method" => "delete",
					   :content => "Delete")
      end
    end
  end
  
  describe "GET 'new'" do
    it "should be successful" do
      get :new
      response.should be_success
    end
    
    it "should have the right title" do
      get :new
      response.should have_selector("title", :content => "Sign up")
    end
    
    it "should have a name field" do
      get :new
      response.should have_selector("input[name='user[username]'][type='text']")
    end
    
    it "should have an email field" do
      get :new
      response.should have_selector("input[name='user[email]'][type='text']")
    end
    
    it "should have a password field" do
      get :new
      response.should have_selector("input[name='user[password]'][type='password']")
    end
    
    it "should have a password_confirmation field" do
      get :new
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end
    
    describe "for registered users" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user))
      end
      
      it "should redirect to the root path" do
	get :new
	response.should redirect_to(root_path)
      end
    end
  end
  
  describe "POST 'create'" do
    describe "failure" do
      
      before(:each) do
	controller.stub!(:verify_recaptcha).and_return(false)
	@attr = { :name => "", :email => "", :password => "asdf",
	          :password_confirmation => "wrong" }
      end
      
      it "should not create a user" do
	lambda do
	  post :create, :user => @attr
	end.should_not change(User, :count)
      end
      
      it "should have the right title" do
	post :create, :user => @attr
	response.should have_selector("title", :content => "Sign up")
      end
      
      it "should render the 'new' page" do
	post :create, :user => @attr
	response.should render_template('new')
      end
      
      describe "if recaptcha is incorrect" do
	
	it "should return a flash error message" do
	  post :create, :user => @attr
	  flash[:error].should =~ /The verification was not correct.  Please try again./
	end
      end
    end
    
    describe "success" do
      before(:each) do
	controller.stub!(:verify_recaptcha).and_return(true)
	@attr = { :username => "New User", :email => "user@example.com",
	  :password => "foobar", :password_confirmation => "foobar" }
      end
      
      it "should create a user" do
	lambda do
	  post :create, :user => @attr
	end.should change(User, :count).by(1)
      end
      
      it "should redirect to the user show page" do
	post :create, :user => @attr
	response.should redirect_to(user_path(assigns(:user)))
      end
      
      it "should have a welcome message" do
	post :create, :user => @attr
	flash[:success].should =~ /successful registration/i
      end
      
      it "should sign the user in" do
	post :create, :user => @attr
	controller.should be_signed_in
      end
    end
    
    describe "for registered users" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user))
      end
      
      it "should redirect to the root path" do
	get :new
	response.should redirect_to(root_path)
      end
    end
  end
  
  describe "GET 'edit'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-signed-in user" do
      it "should deny access" do
	get :edit, :id => @user
	response.should redirect_to(signin_path)
      end
    end
    
    describe "when signed in" do
      
      before(:each) do
	test_sign_in(@user)
      end
      
      it "should be successful" do
	get :edit, :id => @user
	response.should be_success
      end
      
      it "should have a link to change the password" do
	get :edit, :id => @user
	response.should have_selector("a", 
	                :href => user_changepassword_path(@user))
      end
      
      it "should have a Cancel link redirecting to the profile" do
	get :edit, :id => @user
	response.should have_selector("a", :content => "Cancel",
					   :href => user_path(@user))
      end
    end
  end
  
  describe "PUT 'update'" do
    
    describe "as a non-signed-in user" do
      
      it "should not be successful" do
	put :update
	response.should_not be_success
      end
      
      it "should redirect to the signin path" do
	put :update
	response.should redirect_to(signin_path)
      end
    end
    
    describe "failure" do
      
      before(:each) do
	@user = Factory(:user)
	test_sign_in(@user)
	@user.stub!(:image_integrity_error).and_return(true)
	@attr = { :image => File.open("#{Rails.root}/test/fixtures/files/not_an_image.txt") }
      end
      
      it "should not change the image attribute" do
	old_image = @user.image.to_s
	put :update, { :html => { :multipart => true }, :id => @user, :user => @attr }
	@user.reload
	@user.image.to_s.should == old_image
      end
      
      it "should show a flash error message" do
	put :update, { :html => { :multipart => true }, :id => @user, :user => @attr }
	flash[:error].should =~ /Changes could not be saved./
      end
      
      it "should redirect to the 'edit' page" do
	put :update, { :html => { :multipart => true }, :id => @user, :user => @attr }
	response.should render_template('edit')
      end
    end
    
    describe "success" do
 
      before(:each) do
	@user = Factory(:user)
	test_sign_in(@user)
	@user.stub!(:image_integrity_error).and_return(false)
	@attr = { :image => File.open("#{Rails.root}/test/fixtures/files/rails.png") }
      end
      
      it "should change the image attribute" do
	old_image = @user.image.to_s
	put :update, { :html => { :multipart => true }, :id => @user, :user => @attr }
	@user.reload
	@user.image.to_s.should_not == old_image
      end
      
      it "should save to the correct path" do
	put :update, { :html => { :multipart => true }, :id => @user, :user => @attr }
	@user.reload
	@user.image.url.should == "/test_#{@user.id}_avatar.png"
      end
      
      it "should show a flash success message" do
	put :update, { :html => { :multipart => true }, :id => @user, :user => @attr }
	flash[:success].should =~ /Profile updated successfully!/
      end
      
      it "should redirect to the user_path" do
	put :update, { :html => { :multipart => true }, :id => @user, :user => @attr }
	response.should redirect_to(user_path(@user))
      end
    end
    
    describe "validations" do
      
      before(:each) do
	@user = Factory(:user)
	@other_user = Factory(:user, :username => Factory.next(:username),
			      :email => Factory.next(:email))
	test_sign_in(@user)
      end
       
      it "should redirect attempts at editing other users to root path" do
	put :update, :id => @other_user
	response.should redirect_to(root_path)
      end
    end
  end
    
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
    end
    
    describe "as a non-signed-in user" do
      it "should deny access" do
	delete :destroy, :id => @user
	response.should redirect_to(signin_path)
      end
    end
    
    describe "as a non-admin user" do
      it "should protect the page" do
	test_sign_in(@user)
	delete :destroy, :id => @user
	response.should redirect_to(root_path)
      end
    end
    
    describe "as an admin user" do
      
      before(:each) do
	@admin = Factory(:user, { :username => "UniqueUser", 
	                          :email => "admin@example.com", :admin => true })
	test_sign_in(@admin)
      end
      
      it "should destroy the user" do
	lambda do
	  delete :destroy, :id => @user
	end.should change(User, :count).by(-1)
      end
      
      it "should redirect to the root page" do
	delete :destroy, :id => @user
	response.should redirect_to(root_path)
      end
      
      it "should not allow the admin to delete themselves" do
	delete :destroy, :id => @admin
	flash[:error].should =~ /not allowed/i
      end
    end
  end
  
  describe "follow pages" do
    
    describe "when not signed in" do
      
      it "should protect 'following'" do
	get :following, :id => 1
	response.should redirect_to(signin_path)
      end
      
      it "should protect 'followers'" do
	get :followers, :id => 1
	response.should redirect_to(signin_path)
      end
    end
    
    describe "when signed in" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user))
	@other_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	@user.follow!(@other_user)
      end
      
      it "should show user following" do
	get :following, :id => @user
	response.should have_selector("a", :href => user_path(@other_user),
	                                   :content => @other_user.username)
      end
      
      it "should show user followers" do
	get :followers, :id => @other_user
	response.should have_selector("a", :href => user_path(@user),
					   :content => @user.username)
      end
    end
  end
  
  describe "voter pages" do
    
    describe "when not signed in" do
      
      it "should protect the 'voters_for' page" do
	get :voters_for, :id => 1
	response.should redirect_to(signin_path)
      end
      
      it "should protect the 'voters_against' page" do
	get :voters_against, :id => 1
	response.should redirect_to(signin_path)
      end
    end
    
    describe "when signed in" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user))
	@other_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
      end
      
      describe "GET 'voters_for'" do
	
	it "should be successful" do
	  get :voters_for, :id => @other_user
	  response.should be_success
	end
	
	it "should render the 'show_voters' template" do
	  get :voters_for, :id => @other_user
	  response.should render_template('shared/show_voters')
	end
	
	it "should have the right heading content" do
	  get :voters_for, :id => @other_user
	  response.should have_selector("div", :content => "Users respecting")
	end
	
	it "should have a link to the viewed user's page" do
	  get :voters_for, :id => @other_user
	  response.should have_selector("a", :content => @other_user.username,
					     :href => user_path(@other_user))
	end
	
	it "should paginate users" do
	  @users = [@user, @other_user]
	  @user.vote_for(@other_user)
	  30.times do
	    @temp_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	    @temp_user.vote_for(@other_user)
	    @users << @temp_user
	  end
	  get :voters_for, :id => @other_user
	  response.should have_selector("div.pagination")
	  response.should have_selector("span.disabled", :content => "Previous")
	  response.should have_selector("a", :content => "2")
	  response.should have_selector("a", :content => "Next")
	end
      end
      
      describe "GET 'voters_against'" do
	
	it "should be successful" do
	  get :voters_against, :id => @other_user
	  response.should be_success
	end
	
	it "should render the 'show_voters' template" do
	  get :voters_against, :id => @other_user
	  response.should render_template('shared/show_voters')
	end
	
	it "should have the right heading content" do
	  get :voters_against, :id => @other_user
	  response.should have_selector("div", :content => "Users hating on")
	end
	
	it "should have a link to the viewed user's page" do
	  get :voters_against, :id => @other_user
	  response.should have_selector("a", :content => @other_user.username,
					     :href => user_path(@other_user))
	end
	
	it "should paginate users" do
	  @users = [@user, @other_user]
	  @user.vote_against(@other_user)
	  30.times do
	    @temp_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	    @temp_user.vote_against(@other_user)
	    @users << @temp_user
	  end
	  get :voters_against, :id => @other_user
	  response.should have_selector("div.pagination")
	  response.should have_selector("span.disabled", :content => "Previous")
	  response.should have_selector("a", :content => "2")
	  response.should have_selector("a", :content => "Next")
	end
      end
    end
  end
  
  describe "GET 'beef_with'" do
    
    describe "when not signed in" do
      
      it "should deny access" do
	get :beef_with, :id => 1
	response.should redirect_to(signin_path)
      end
    end
    
    describe "when signed in" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user))
	@other_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
      end
      
      it "should be successful" do
	get :beef_with, :id => @other_user
	response.should be_success
      end
      
      it "should have a link to the other user's profile" do
	get :beef_with, :id => @other_user
	response.should have_selector("a", :content => @other_user.username,
					   :href => user_path(@other_user))
      end
      
      it "should show insults where the current user is the insulter and the other user insulted" do
	insult = @other_user.add_insult!(@user, "Content")
	get :beef_with, :id => @other_user
	response.should have_selector("div", :content => insult.content)
      end
      
      it "should show insults where the other user is the insulter and the current user insulted" do
	insult = @user.add_insult!(@other_user, "Content")
	get :beef_with, :id => @other_user
	response.should have_selector("div", :content => insult.content)
      end
      
      it "should not show insults involving other parties" do
	third_user = Factory(:user, :username => Factory.next(:username),
				    :email => Factory.next(:email))
	insult = third_user.add_insult!(@other_user, "Content")
	get :beef_with, :id => @other_user
	response.should_not have_selector("div", :content => insult.content)
      end
      
      it "should paginate results" do
	insult = @other_user.add_insult!(@user, "Content")
	@insults = [insult]
	31.times do
	  @insults << Factory(:insult, :insulter => @user, :insulted => @other_user)
	end
	get :beef_with, :id => @other_user
	response.should_not have_selector("div", :content => insult.content)
	response.should have_selector("div.pagination")
	response.should have_selector("span.disabled", :content => "Previous")
	response.should have_selector("a", :content => "2")
	response.should have_selector("a", :content => "Next")
      end
    end
  end
end
