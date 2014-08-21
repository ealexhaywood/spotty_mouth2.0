require 'spec_helper'

describe VotesController do
  
  before(:each) do
    @user = Factory(:user)
    @other_user = Factory(:user, :username => Factory.next(:username),
	      		         :email => Factory.next(:email))
    @insult = @user.add_insult!(@other_user, "Content")
  end
    
  describe "access control" do
    
    it "for voting up insults should require the user to be logged in" do
      post :vote_up_insult, :id => @insult
      response.should redirect_to(signin_path)
    end
    
    it "for voting up people should require the user to be logged in" do
      post :vote_up_user, :id => @user
      response.should redirect_to(signin_path)
    end
    
    it "for voting down insults should require the user to be logged in" do
      post :vote_down_insult, :id => @insult
      response.should redirect_to(signin_path)
    end
    
    it "for voting down people should require the user to be logged in" do
      post :vote_down_user, :id => @user
      response.should redirect_to(signin_path)
    end
  end

  describe "POST 'vote_up_insult'" do
    
    before(:each) do
      test_sign_in(@user)
    end
    
    it "should increase the insult's votes by one" do
      lambda do
	post :vote_up_insult, :id => @insult
	@insult.reload
      end.should change(@insult, :votes_for).by(1)
    end
    
    it "should increase the insult's votes by one via AJAX" do
      lambda do
	xhr :post, :vote_up_insult, :id => @insult
	response.should be_success
      end.should change(@insult, :votes_for).by(1)
    end
      
    it "should only allow a maximum of one up vote from a given user" do
      post :vote_up_insult, :id => @insult.id
      post :vote_up_insult, :id => @insult.id
      @insult.reload
      @insult.votes_for.should == 1
    end
  end
  
  describe "POST 'vote_up_user'" do
    
    before(:each) do
      test_sign_in(@user)
    end
    
    it "should increase the receiver's votes by one" do
      lambda do
	post :vote_up_user, :id => @other_user.id
	@other_user.reload
      end.should change(@other_user, :votes_for).by(1)
    end
    
    it "should increase the receiver's votes by one via AJAX" do
      lambda do
	xhr :post, :vote_up_user, :id => @other_user.id
	response.should be_success
      end.should change(@other_user, :votes_for).by(1)
    end
    
    it "should only allow a maximum of one up vote from a given user" do
      post :vote_up_user, :id => @other_user.id
      post :vote_up_user, :id => @other_user.id
      @other_user.reload
      @other_user.votes_for.should == 1
    end
  end
  
  describe "DELETE 'vote_down_insult'" do
    
    before(:each) do
      test_sign_in(@user)
    end
    
    it "should increase the insult's votes_against by one" do
      lambda do
	post :vote_down_insult, :id => @insult.id
	@insult.reload
      end.should change(@insult, :votes_against).by(1)
    end
    
    it "should increase the insult's votes_against by one via AJAX" do
      lambda do
	xhr :post, :vote_down_insult, :id => @insult.id
	response.should be_success
      end.should change(@insult, :votes_against).by(1)
    end
    
    it "should only allow a maximum of one down vote from a given user" do
      post :vote_down_insult, :id => @insult.id
      post :vote_down_insult, :id => @insult.id
      @insult.reload
      @insult.votes_against.should == 1
    end
  end
  
  describe "DELETE 'vote_down_user'" do
    
    before(:each) do
      test_sign_in(@user)
    end
    
    it "should increase the receiver's votes_against by one" do
      lambda do
	post :vote_down_user, :id => @other_user.id
	@other_user.reload
      end.should change(@other_user, :votes_against).by(1)
    end
    
    it "should increase the receiver's votes_against by one via AJAX" do
      lambda do
	xhr :post, :vote_down_user, :id => @other_user.id
	response.should be_success
      end.should change(@other_user, :votes_against).by(1)
    end
    
    it "should only allow a maximum of one down vote from a given user" do
      post :vote_down_user, :id => @other_user.id
      post :vote_down_user, :id => @other_user.id
      @other_user.reload
      @other_user.votes_against.should == 1
    end
  end
end
