require 'spec_helper'

describe "Users" do
  
  describe "signup" do
  
    describe "failure" do
      
      it "should not make a new user" do
	lambda do
	  visit signup_path
	  fill_in "Username",		:with => ""
	  fill_in "Email",		:with => ""
	  fill_in "Password",		:with => ""
	  fill_in "Confirmation",	:with => ""
	  click_button "Sign up"
	  page.should have_selector("div#error_explanation")
	end.should_not change(User, :count)
      end
    end    
    
    describe "success" do
      
      it "should make a new user" do
	lambda do
	  visit signup_path
	  fill_in "Username",		:with => "Example User"
	  fill_in "Email",		:with => "user@example.com"
	  fill_in "Password",		:with => "foobar"
	  fill_in "Confirmation",	:with => "foobar"
	  click_button "Sign up"
	  # response.should render_template('users/show')
	  page.should have_selector("div.flash.success", 
	                                :content => "Successful Registration!")
	end.should change(User, :count).by(1)
      end
    end
  end
  
  describe "sign in/out" do
    
    describe "failure" do
      it "should not sign a user in" do
	user = User.new
	integration_sign_in(user)
	page.should have_selector("div.flash.error", :content => "Invalid")
      end
    end
    
    describe "success" do
      it "should sign a user in and out" do
	user = Factory(:user)
	visit signin_path
	fill_in "session_email",		:with => user.email
	fill_in "session_password",	:with => user.password
	click_button "session_submit"
	# integration_sign_in(Factory(:user))
	# controller.should be_signed_in
	# save_and_open_page
	puts body
	puts page
	puts Capybara.default_selector 
	page.should have_no_selector("Sign in")
	with_scope("header") do
	  page.should have_link('Sign out')
	end
	# controller.should_not be_signed_in
	page.should have_selector("Sign in")
      end
    end
  end
end
