require 'spec_helper'

describe "Votes" do

  before(:each) do
    @user = Factory(:user)
    @user2 = Factory(:user, :username => Factory.next(:username),
			    :email => Factory.next(:email))
    @insult = @user2.add_insult!(@user, "Content")
    integration_sign_in(@user)
    click_link "Find Victim"
    fill_in "search",	    :with => @user2.username
    click_button "Search"
    click_link @user2.username
  end
  
  describe "vote_up_user" do
    
    it "should update the user rating, arrows and vote links" do
      click_link "user_up_arrow"
      page.should have_selector("img", :alt => "Uparrowbigselect")
      page.should have_selector("img", :alt => "Downarrowbig")
      page.should have_selector("#hater_rating", :content => "1")
      page.should have_selector("a", :id => "votes_for_link",
				     :content => "1 vote for",
				     :href => "/users/#{@user2.id}/voters_for")
      page.should have_selector("a", :id => "votes_against_link",
				     :content => "0 votes against",
				     :href => "/users/#{@user2.id}/voters_against")
    end
  end
  
  describe "vote_down_user" do
    
    it "should update the user rating, arrows and vote links" do
      click_link "user_down_arrow"
      page.should have_selector("img", :alt => "Uparrowbig")
      page.should have_selector("img", :alt => "Downarrowbigselect")
      page.should have_selector("#hater_rating", :content => "-1")
      page.should have_selector("a", :id => "votes_for_link",
				      :content => "0 votes for",
				      :href => "/users/#{@user2.id}/voters_for")
      page.should have_selector("a", :id => "votes_against_link",
				     :content => "1 vote against",
				     :href => "/users/#{@user2.id}/voters_against")
    end
  end
  
  describe "vote_up_insult" do
    
    it "should update the insult rating and arrows" do
      click_link "uparrow#{@insult.id}"
      page.should have_selector("#insult_rating#{@insult.id}", :content => "1")
      page.should have_selector("img", :alt => "Uparrowselect")
      page.should have_selector("img", :alt => "Downarrow")
    end
  end
  
  describe "vote_down_insult" do
    
    it "should update the insult rating and arrows" do
      click_link "downarrow#{@insult.id}"
      page.should have_selector("#insult_rating#{@insult.id}", :content => "-1")
      page.should have_selector("img", :alt => "Uparrow")
      page.should have_selector("img", :alt => "Downarrowselect")
    end
  end
end
      
	