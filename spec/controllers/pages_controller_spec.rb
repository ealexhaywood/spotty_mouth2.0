require 'spec_helper'

describe PagesController do
  render_views

  describe "GET 'home'" do
    
    describe "when not signed in" do
      
      before(:each) do
	get :home
      end
      
      it "should be successful" do
	response.should be_success
      end

      it "should have the right title" do
	response.should have_selector("title",
	                              :content => "The Home of Burns and Insults - Spotty Mouth")
      end
      
      it "should have the right content" do
	response.should have_selector("h1", :content => "What is Spotty Mouth?")
      end
    end
    
    describe "when signed in" do
      
      before(:each) do
	@user = test_sign_in(Factory(:user))
	@second_user = Factory(:user, :username => Factory.next(:username),
					  :email => Factory.next(:email))
	@third_user = Factory(:user, :username => Factory.next(:username),
					  :email => Factory.next(:email))
      end
      
      it "should have the right content" do
	get :home
	response.should have_selector("p", :content => "Burns by all the haters you've got an eye on")
      end
      
      it "should have a link to the user's 'following' page" do
	get :home
	response.should have_selector("a", :href => following_user_path(@user))
      end
      
      it "should show insults on the wall of people the current user is following" do
	@insult = @second_user.add_insult!(@third_user, "content")
	@user.follow!(@second_user)
	get :home
	response.should have_selector("p", :content => @insult.content)
      end
      
      it "should show insults by people the current user is following" do
	@insult = @third_user.add_insult!(@second_user, "content")
	@user.follow!(@second_user)
	get :home
	response.should have_selector("p", :content => @insult.content)
      end
      
      it "should not show insults if the user is not following the insulted or insulter" do
	@insult = @third_user.add_insult!(@second_user, "content")
	get :home
	response.should_not have_selector("p", :content => @insult.content)
      end
      
      it "should not show insults older than 3 days" do
	@insult = Factory(:insult, :insulter => @second_user, :insulted => @third_user,
				   :created_at => 4.days.ago)
	get :home
	response.should_not have_selector("p", :content => @insult.content)
      end
      
      it "should paginate results" do
	@insults = []
	31.times do
	  @insults << @second_user.add_insult!(@third_user, "content")
	end
	@user.follow!(@second_user)
	get :home
	response.should have_selector("div.pagination")
	response.should have_selector("span.disabled", :content => "Previous")
	response.should have_selector("a", :content => "2")
	response.should have_selector("a", :content => "Next")
      end
    end
  end

  describe "GET 'contact'" do
    it "should be successful" do
      get :contact
      response.should be_success
    end
    
    it "should have the right title" do
      get :contact
      response.should have_selector("title", 
                                    :content => "Best insults the internet has to offer - Spotty Mouth")
    end
    
    it "should have a link to the terms and conditions" do
      get :contact
      response.should have_selector("a", :href => '/terms_and_conditions',
					 :content => "Terms and Conditions")
    end
  end
  
  describe "GET 'find_victim'" do
    
    it "should be successful" do
      get :find_victim
      response.should be_success
    end
    
    it "should have the right title" do
      get :find_victim
      response.should have_selector("title", 
                                    :content => "Make fun of a hater - Spotty Mouth Search")
    end
    
    describe "with search parameters that are" do
      
      before(:each) do
	@user = Factory(:user)
	@user2 = Factory(:user, :username => Factory.next(:username),
	                           :email => Factory.next(:email))
	@users = [@user, @user2]
	14.times do
	  @users << Factory(:user, :username => Factory.next(:username),
	                           :email => Factory.next(:email))
	end
      end
      
      it "nil should show the newest 15 users" do
	get :find_victim
	response.should have_selector("div", :content => @user2.username)
      end
      
      it "nil should not show older than 15 users" do
	get :find_victim
	response.should_not have_selector("div", :content => @user.username)
      end
      
      it "blank should show the newest 15 users" do
	get :find_victim, :search => ""
	response.should have_selector("div", :content => @user2.username)
      end
      
      it "blank should not show older than 15 users" do
	get :find_victim, :search => ""
	response.should_not have_selector("div", :content => @user.username)
      end
    end
    
    describe "with search parameters" do
     
      before(:each) do
	@user = Factory(:user)
      end
      
      it "should render the searched user" do
	get :find_victim, :search => @user.username
	response.should have_selector("div", :content => @user.username)
      end
      
      it "should notify the user if no results are found" do
	@users = [@user]
	31.times do
	  @users << Factory(:user, :username => Factory.next(:username),
	                           :email => Factory.next(:email))
	end
	get :find_victim, :search => "YouCannotFindThis"
	response.should have_selector("p", :content => "No Results You Fool")
      end
	
      it "should paginate the results" do
	@users = [@user]
	31.times do
	  @users << Factory(:user, :username => Factory.next(:username),
	                           :email => Factory.next(:email))
	end
	get :find_victim, :search => "Person"
	response.should have_selector("div.pagination")
	response.should have_selector("span.disabled", :content => "Previous")
	response.should have_selector("a", :content => "2")
	response.should have_selector("a", :content => "Next")
      end
    end
  end
  
  describe "GET 'terms_and_conditions'" do
    
    it "should be successful" do
      get :terms_and_conditions
      response.should be_success
    end
    
    it "should have the right content" do
      get :terms_and_conditions
      response.should have_selector("h2", :content => "TERMS AND CONDITIONS")
    end
  end
end
