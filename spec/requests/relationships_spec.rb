require 'spec_helper'

describe "Relationships" do
  
  before(:each) do
    @user = Factory(:user)
    @user2 = Factory(:user, :username => Factory.next(:username),
			    :email => Factory.next(:email))
    integration_sign_in(@user)
    click_link "Find Victim"
    fill_in "search",	    :with => @user2.username
    click_button "Search"
    click_link @user2.username
  end
  
  describe "follow" do
    
    it "should update the follow form to the unfollow form" do
      click_button "relationship_submit"
      # assert_response :success
      # response.should render_template('users/_unfollow')
      page.should have_selector("#followers", 
                                    :content => "1 user preying on this hater")
    end
  end
  
  describe "unfollow" do
    
    it "should update the unfollow form to the follow form" do
      click_button "relationship_submit"
      click_button "relationship_submit"
      # assert_response :success
      # response.should render_template('users/_follow')
      page.should have_selector("#followers",
                                    :content => "0 users preying on this hater")
    end
  end
end
      
	