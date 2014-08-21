require 'spec_helper'

describe "Insults" do
  
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
  
  describe "delete" do
    
    it "should remove insults from the user page" do
      page.should have_selector(".insult")
      click_link "Delete"
      page.should have_no_selector(".insult")
    end
  end
end