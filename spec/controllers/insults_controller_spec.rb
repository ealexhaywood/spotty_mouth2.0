require 'spec_helper'

describe InsultsController do
  render_views
  
  describe "GET 'index'" do
    
    before(:each) do 
      @insulter = Factory(:user)
    end
    
    describe "when not signed in" do
      
      it "should redirect to the signin page" do
	get :index, :user_id => @insulter
	response.should redirect_to(signin_path)
      end
    end
    
    describe "for signed in users" do
      
      before(:each) do
	test_sign_in(@insulter)
      end
    
      it "should be successful" do
	get :index, :user_id => @insulter
	response.should be_success
      end
      
      it "should show the insults by the user" do
	@insulted = Factory(:user, :username => Factory.next(:username),
				  :email => Factory.next(:email))
	@insult = Factory(:insult, :insulter => @insulter, 
				  :insulted => @insulted)
	get :index, :user_id => @insulter
	response.should have_selector("div", :content => @insult.content)
      end
      
      it "should paginate insults" do
	@insulted = Factory(:user, :username => Factory.next(:username),
				  :email => Factory.next(:email))
	@insults = []
	31.times do 
	  @insults << Factory(:insult, :insulter => @insulter,
				       :insulted => @insulted,
				       :content => Factory.next(:content))
	end
	get :index, :user_id => @insulter
	response.should have_selector("div.pagination")
	response.should have_selector("span.disabled", :content => "Previous")
	response.should have_selector("a", :content => "2")
	response.should have_selector("a", :content => "Next")
      end
      
      it "should link to the insulted's wall" do
	@insulted = Factory(:user, :username => Factory.next(:username),
				  :email => Factory.next(:email))
	@insulted.add_insult!(@insulter, "Content")
	get :index, :user_id => @insulter
	response.should have_selector("a", :href => user_path(@insulted),
					  :content => @insulted.username)
      end
      
      describe "viewing their own insults index" do
	
	before(:each) do
	  @insulted = Factory(:user, :username => Factory.next(:username),
				  :email => Factory.next(:email))
	  @insult = Factory(:insult, :insulter => @insulter, 
				  :insulted => @insulted)
	end
	
	it "should show insult delete links" do
	  get :index, :user_id => @insulter
	  response.should have_selector("a", :href => insult_path(@insult),
					     :"data-method" => "delete",
					     :content => "Delete")
	end
      end
      
      describe "viewing other users' insult indexes" do
	
	before(:each) do
	  @insulted = Factory(:user, :username => Factory.next(:username),
				  :email => Factory.next(:email))
	  @other_user = Factory(:user, :username => Factory.next(:username),
				       :email => Factory.next(:email))
	  @insult = Factory(:insult, :insulter => @other_user, 
				  :insulted => @insulted)
	end
	
	it "should not show insult delete links" do
	  get :index, :user_id => @other_user
	  response.should_not have_selector("a", :href => insult_path(@insult),
					     :"data-method" => "delete",
					     :content => "Delete")
	end
      end
      
      describe "as admins viewing an index" do
	
	before(:each) do
	  @insulted = Factory(:user, :username => Factory.next(:username),
				  :email => Factory.next(:email))
	  @insult = Factory(:insult, :insulter => @insulter, 
				  :insulted => @insulted)
	  @admin = Factory(:user, :username => Factory.next(:username),
				  :email => Factory.next(:email),
				  :admin => true)
	  test_sign_out(@insulter)
	  test_sign_in(@admin)
	end
	
	it "should show the user delete links" do
	  get :index, :user_id => @insulter
	  response.should have_selector("a", :href => insult_path(@insult),
					     :"data-method" => "delete",
					     :content => "Delete")
	end
      end
    end
  end

  describe "POST 'create'" do
    
    before(:each) do
      @insulter = Factory(:user)
      @insulted = Factory(:user, :username => Factory.next(:username),
				 :email => Factory.next(:email))
    end
    
    describe "failure" do
      
      before(:each) do
	test_sign_in(@insulter)
	@attr = { :insulter_id => @insulter, :content => "" }
      end
      
      it "should not create a new insult" do
	lambda do
	  post :create, :user_id => @insulted.id, :insult => @attr
	end.should_not change(Insult, :count)
      end
      
      it "should render to the insulted's page" do
	post :create, :user_id => @insulted.id, :insult => @attr
	response.should render_template('users/show')
      end
      
      it "should show a flash error message" do
	post :create, :user_id => @insulted.id, :insult => @attr
	flash[:error].should =~ /Your game is too weak./
      end
    end
    
    describe "success" do
      
      before(:each) do
	test_sign_in(@insulter)
	@attr = { :insulter_id => @insulter, :content => "Content" }
      end
      
      it "should create a new insult" do
	lambda do
	  post :create, :user_id => @insulted.id, :insult => @attr
	end.should change(Insult, :count).by(1)
      end
      
      it "should redirect to the insulted's page" do
	post :create, :user_id => @insulted.id, :insult => @attr
	response.should redirect_to user_path(@insulted)
      end
      
      it "should show a flash success message" do
	post :create, :user_id => @insulted.id, :insult => @attr
	flash[:success].should =~ /You just spat some fire./
      end
    end
    
    describe "validations" do
      
      before(:each) do
	@attr = { :insulter_id => @insulter, :content => "Content" }
      end
      
      it "should require the insulter to be logged in" do	
	lambda do
	  post :create, :user_id => @insulted.id, :insult => @attr
	end.should_not change(Insult, :count)
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
	@insult = @other_user.add_insult!(@user, "Content")
      end
      
      describe "GET 'voters_for'" do
	
	before(:each) do
	  @user.vote_for(@insult)
	end
	
	it "should be successful" do
	  get :voters_for, :id => @insult
	  response.should be_success
	end
	
	it "should render the 'show_voters' template" do
	  get :voters_for, :id => @insult
	  response.should render_template('shared/show_voters')
	end
	
	it "should have the right heading content" do
	  get :voters_for, :id => @insult
	  response.should have_selector("div", :content => "Users respecting")
	end
	
	it "should have a link to the viewed insult's insulted page" do
	  get :voters_for, :id => @insult
	  response.should have_selector("a", :content => @insult.content,
					     :href => user_path(@insult.insulted))
	end
	
	it "should paginate users" do
	  @users = [@user, @other_user]
	  30.times do
	    @temp_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	    @temp_user.vote_for(@insult)
	    @users << @temp_user
	  end
	  get :voters_for, :id => @insult
	  response.should have_selector("div.pagination")
	  response.should have_selector("span.disabled", :content => "Previous")
	  response.should have_selector("a", :content => "2")
	  response.should have_selector("a", :content => "Next")
	end
      end
      
      describe "GET 'voters_against'" do
	
	before(:each) do
	  @user.vote_against(@insult)
	end
	
	it "should be successful" do
	  get :voters_against, :id => @insult
	  response.should be_success
	end
	
	it "should render the 'show_voters' template" do
	  get :voters_against, :id => @insult
	  response.should render_template('shared/show_voters')
	end
	
	it "should have the right heading content" do
	  get :voters_against, :id => @insult
	  response.should have_selector("div", :content => "Users hating on")
	end
	
	it "should have a link to the viewed user's page" do
	  get :voters_against, :id => @insult
	  response.should have_selector("a", :content => @insult.content,
					     :href => user_path(@insult.insulted))
	end
	
	it "should paginate users" do
	  @users = [@user, @other_user]
	  30.times do
	    @temp_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	    @temp_user.vote_against(@insult)
	    @users << @temp_user
	  end
	  get :voters_against, :id => @insult
	  response.should have_selector("div.pagination")
	  response.should have_selector("span.disabled", :content => "Previous")
	  response.should have_selector("a", :content => "2")
	  response.should have_selector("a", :content => "Next")
	end
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @user = Factory(:user)
      @insulter = Factory(:user, :username => Factory.next(:username),
				:email => Factory.next(:email))
      @insulted = Factory(:user, :username => Factory.next(:username),
				:email => Factory.next(:email))
      @insult = @insulted.add_insult!(@insulter, "Content")
    end
    
    it "should redirect non-logged in users to the root path" do
      delete :destroy, :id => @insult
      response.should redirect_to(root_path)
    end
    
    it "should reject attempts to delete insults by non-insulted/insulter" do
      test_sign_in(@user)
      delete :destroy, :id => @insult
      response.should redirect_to(root_path)
    end
    
    it "should allow the insulter to delete insults" do
      test_sign_in(@insulter)
      delete :destroy, :id => @insult
      response.should redirect_to(user_path(@insulted))
    end
    
    it "should allow the insulted to delete insults" do
      test_sign_in(@insulted)
      delete :destroy, :id => @insult
      response.should redirect_to(user_path(@insulted))
    end
    
    it "should allow admins to delete insults" do
      @admin_user = Factory(:user, :username => Factory.next(:username),
				        :email => Factory.next(:email),
				        :admin => true)
      test_sign_in(@admin_user)
      delete :destroy, :id => @insult
      response.should redirect_to(user_path(@insulted))
    end
    
    describe "success" do
      
      before(:each) do
	test_sign_in(@insulted)
      end
      
      it "should destroy an insult" do
	lambda do
	  delete :destroy, :id => @insult
	end.should change(Insult, :count).by(-1)
      end
      
      it "should display a flash success message" do
	delete :destroy, :id => @insult
        flash[:success].should == "Insult deleted."
      end
    end
  end
end
