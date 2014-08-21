require 'spec_helper'

describe "LayoutLinks" do

=begin    it "should have a page at '/'" do
      visit '/'
      response.status.should be(200)
    end
    
    it "should have a page at '/contact'" do
      visit 'contact'
      response.should be_success
    end
    
    it "should have a signup page at '/signup'" do
      visit '/signup'
      response.should have_selector('title', :content => "Sign up")
    end
    
    it "should have a page at '/findvictim'" do
      visit '/findvictim'
      response.should be_success
=end    end
    
    it "should have the right links on the layout" do
      visit root_path
        
      click_link "Contact"
      page.should have_selector('h1', :content => "Contact")

      click_link "Home"
      page.should have_selector('h1', :content => "What is Spotty Mouth?")
      
      click_link "Find Victim"
      page.should have_selector("h1", :content => "Find Victim")
      
      click_link "Sign in"
      page.should have_selector('h1', :content => "Sign in")
      
      click_link "Wall of Fame"
      page.should have_selector("th", :content => "Today's Best Haters")
      
      click_link "Wall of Shame"
      page.should have_selector("th", :content => "Today's Worst Haters")
      
      click_link "Daily Question"
      page.should have_selector("h1", :content => "Question of the Day")
    end
    
    describe "when not signed in" do
      it "should have a signin link" do
	visit root_path
	page.should have_selector("a", :href => signin_path,
					    :content => "Sign in")
      end
    end
    
    describe "when signed in" do
      
      before(:each) do
	@user = Factory(:user)
	visit signin_path
	fill_in :email,		:with => @user.email
	fill_in :password,	:with => @user.password
	click_button "Sign in"
      end
      
      it "should have a profile link" do
	visit root_path
	page.should have_selector("a", :href => user_path(@user.id),
					   :content => "Profile")
      end
      
      it "should have a signout link" do
	visit root_path
	page.should have_selector("a", :href => signout_path,
	                              :content => "Sign out")
      end
    end
end
