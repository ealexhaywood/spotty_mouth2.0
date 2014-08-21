require 'spec_helper'
require 'action_mailer'

 describe PasswordsController do
   render_views
   
   before(:each) do
     @user = Factory(:user)
   end
   
   describe "GET 'new'" do
     
     it "should have the right title" do
       get :new
       response.should have_selector("title", :content => "Forgot Password")
     end
     
     describe "for signed in users" do
       
       before(:each) do
	 test_sign_in(@user)
       end
       
       it "should redirect to the root path" do
	 get :new
	 response.should redirect_to(root_path)
       end
     end
   end
   
   describe "POST 'create'" do
     
     describe "for signed in users" do
       
       before(:each) do
	 test_sign_in(@user)
       end
       
       it "should redirect to the root path" do
	 post :create, :email => @user.email
	 response.should redirect_to(root_path)
       end
       
       it "should not change the password" do
	 old_password = @user.encrypted_password
	 post :create, :email => @user.email
	 @user.reload
	 @user.encrypted_password.should == old_password
       end
     end
     
     describe "without a valid captcha" do
       
      before(:each) do
	controller.stub!(:verify_recaptcha).and_return(false)
        post :create, :email => @user.email
      end
       
      it "should render the 'passwords/new' template" do
	response.should render_template('passwords/new')
      end
      
      it "should display a flash error message" do
	flash[:error].should  =~ /The verification was not correct.  Please try again./
      end
     end
      
     describe "failure" do
       
      before(:each) do
	post :create, :email => "NotARealEmailAddress@NoSite.com" 
      end
       
      it "should render the 'new' page" do
	response.should render_template('passwords/new')
      end
      
      it "should show a flash error message for failures" do
	flash[:error].should  =~ /The provided email account does not exist./
      end
     end
     
     describe "success" do
       
       before(:each) do
	 @old_password = @user.encrypted_password
	 post :create, :email => @user.email
       end
     
       it "should redirect to the home page" do
	 response.should redirect_to root_path
       end
       
	it "should show a flash success message" do
	  flash[:success].should =~ /A new password has been sent to your email./
	end
	
	it "should change the user's password" do
	  @user.reload
	  @user.encrypted_password.should_not == @old_password
	end
      end  
      
      it "on success should pass a user object to the UserNotifier new_password method" do
	@mail = UserNotifier.new_password(@user, anything)
	UserNotifier.should_receive(:new_password).and_return(@mail.deliver)
	post :create, :email => @user.email
      end
   end
   
   describe "GET 'edit'" do
     
     describe "if not logged in" do
       
       it "should not be successful" do
	 get :edit, :user_id => @user
	 response.should_not be_success
       end
       
       it "should redirect to the sign in page" do
	 get :edit, :user_id => @user
	 response.should redirect_to(signin_path)
       end
     end
     
     describe "when logged in" do
       
       before(:each) do
	 test_sign_in(@user)
       end
       
       it "should be valid" do
	 get :edit, :user_id => @user.id
	 response.should be_success
       end
       
       it "should render the password edit page" do
	 get :edit, :user_id => @user.id
	 response.should render_template('edit')
       end
       
       it "should have a Cancel link redirecting to the profile" do
	 get :edit, :user_id => @user.id
	 response.should have_selector("a", :content => "Cancel",
					    :href => user_path(@user))
       end
     end
     
      describe "validations" do
       
       before(:each) do
	 @other_user = Factory(:user, :username => Factory.next(:username),
				      :email => Factory.next(:email))
	 test_sign_in(@user)
       end
       
       it "should redirect attempts at viewing other users to root path" do
	 get :edit, :user_id => @other_user
	 response.should redirect_to(root_path)
       end
     end
   end
   
   describe "PUT 'update'" do
     
     describe "if not logged in" do
       
       it "should not be successful" do
	 put :update, :user_id => @user
	 response.should_not be_success
       end
       
       it "should redirect to the sign in page" do
	 put :update, :user_id => @user
	 response.should redirect_to(signin_path)
       end
     end
     
     describe "failure" do
       
       before(:each) do
	 @attr = { :password => "foobar", :password_confirmation => "a" }
	 test_sign_in(@user)
       end
       
       it "should render the edit page" do
	 put :update, :user_id => @user, :user => @attr
	 response.should render_template('passwords/edit')
       end
       
       it "should show a flash error message" do
	 put :update, :user_id => @user, :user => @attr
	 flash[:error].should =~ /User could not be verified/
       end
       
       it "should not change the encrypted_password" do
	 lambda do
	   put :update, :user_id => @user, :old_password => @old_password, :user => @attr
	 end.should_not change(@user, :encrypted_password)
       end
       
       describe "with valid login credentials" do
	 
	 before(:each) do
	   @old_password = @user.password
	   @attr2 = { :password => "wrong", :password_confirmation => "foobar"}
	   put :update, :user_id => @user, :old_password => @old_password, :user => @attr2
	 end
	 
	 it "should show a flash error message" do
	  flash[:error].should =~ /Password could not be changed./
	 end
	 
	 it "should reset the password boxes" do
	   response.should have_selector("input#old_password",
	                                 :content => "")
	   response.should have_selector("input#user_password",
	                                 :content => "")
	   response.should have_selector("input#user_password_confirmation",
	                                 :content => "")
	 end
       end
     end
     
     describe "success" do
       
       before(:each) do
	 test_sign_in(@user)
	 @old_password = @user.password
	 @attr = { :password =>"NewFoo", :password_confirmation => "NewFoo" }
       end
       
       it "should change the encrypted_password" do
	 lambda do
	   put :update, :user_id => @user, :old_password => @old_password, :user => @attr
	 end.should change(@user, :encrypted_password)
       end
       
       it "should show a flash success message" do
	 put :update, :user_id => @user, :old_password => @old_password, :user => @attr
	 flash[:success].should =~ /Password successfully changed./
       end
     end
     
     describe "validations" do
       
       before(:each) do
	 @other_user = Factory(:user, :username => Factory.next(:username),
				      :email => Factory.next(:email))
	 test_sign_in(@user)
	 @old_password = @other_user.password
	 @attr = { :password =>"NewFoo", :password_confirmation => "NewFoo" }
       end
       
       it "should not change encrypted_password if new password is too short" do
	 short = "short"
	 @attr2 = { :password => short, :password_confirmation => short }
	 lambda do
	  put :update, :user_id => @user, :old_password => @user.password, :user => @attr2
	 end.should_not change(@user, :encrypted_password)
       end
	 
       it "not change encrypted_password if new password is too long" do
	 long = "a" * 41
	 @attr2 = { :password => long, :password_confirmation => long }
	 lambda do
	   put :update, :user_id => @user, :old_password => @user.password, :user => @attr2
	 end.should_not change(@user, :encrypted_password)
       end
       
       it "should not allow a user to change another user's password" do
	 put :update, :user_id => @other_user, :old_password => @old_password, :user => @attr
	 @other_user.password.should == @old_password
       end
       
       it "should redirect attempts at changing other users to root path" do
	 put :update, :user_id => @other_user, :old_password => @old_password, :user => @attr
	 response.should redirect_to(root_path)
       end
     end
   end
 end