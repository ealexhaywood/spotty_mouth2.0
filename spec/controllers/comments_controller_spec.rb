require 'spec_helper'

describe CommentsController do
  render_views
  
  before(:each) do
    @insulter = Factory(:user)
    @insulted = Factory(:user, :username => Factory.next(:username),
			       :email => Factory.next(:email))
    @insult = Factory(:insult, :insulter => @insulter, :insulted => @insulted)
  end
  
  describe "GET index'" do
    
    it "should be successful" do
      get :index, :insult_id => @insult.id
      response.should be_success
    end
    
    it "should paginate comments" do
      31.times do
	@insult.comments.create!(:commenter_id => @insulter.id, :content => "Foo bar")
      end
      get :index, :insult_id => @insult.id
      response.should have_selector("div.pagination")
      response.should have_selector("span.disabled", :content => "Previous")
      response.should have_selector("a", :content => "2")
      response.should have_selector("a", :content => "Next")
    end
    
    it "should have a prompt to signin or register to leave comments" do
      get :index, :insult_id => @insult.id
      response.should have_selector("a", :content => "login",
					 :href => signin_path)
      response.should have_selector("a", :content => "register",
					 :href => signup_path)
      response.should have_selector("p.login_prompt", :content => "comment")
    end
    
    it "should not have a form to leave a new comment" do
      get :index, :insult_id => @insult.id
      response.should_not have_selector("textarea")
      response.should_not have_selector("input")
    end
    
    it "should not have a link to itself" do
      get :index, :insult_id => @insult.id
      response.should_not have_selector("a", :href => insult_comments_path(@insult))
    end
    
    describe "for signed in users" do
      
      before(:each) do
	@third_user = Factory(:user, :username => Factory.next(:username),
			       :email => Factory.next(:email))
	@comment = Factory(:comment, :insult => @insult, :commenter => @third_user)
	test_sign_in(@insulter)
      end
      
      it "should not have a prompt to signin or register to leave comments" do
	get :index, :insult_id => @insult.id
	response.should_not have_selector("a", :content => "login",
					 :href => signin_path)
	response.should_not have_selector("a", :content => "register",
					 :href => signup_path)
	response.should_not have_selector("p.login_prompt", :content => "comment")
      end
      
      it "should have a form to leave a new comment" do
	get :index, :insult_id => @insult
	response.should have_selector("form", :method => "post",
					      :action => "/insults/#{@insult.id}/comments")
      end
      
      describe "viewing comments for an insult on their own wall" do
	
	before(:each) do
	  test_sign_in(@insulted)
	end
	
	it "should show delete links for comments" do
	  get :index, :insult_id => @insult.id
	  response.should have_selector("a", :content => "Delete",
					     :href => "/comments/#{@comment.id}",
					     :"data-method" => "delete")
	end
      end
      
      describe "viewing comments which they left behind" do
	
	before(:each) do
	  test_sign_in(@third_user)
	end
	
	it "should show delete links for comments" do
	  get :index, :insult_id => @insult.id
	  response.should have_selector("a", :content => "Delete",
					     :href => "/comments/#{@comment.id}",
					     :"data-method" => "delete")
	end
      end
      
      describe "viewing comments they did not post which are not on their wall" do
	
	before(:each) do
	  test_sign_in(@insulter)
	end
	
	it "should not show delete links for comments" do
	  get :index, :insult_id => @insult.id
	  response.should_not have_selector("a", :content => "Delete",
						 :href => "/comments/#{@comment.id}")
	end
      end
      
      describe "as an admin user" do
	
	before(:each) do
	  @admin_user = Factory(:user, :username => Factory.next(:username),
			       :email => Factory.next(:email), :admin => true)
	  test_sign_in(@admin_user)
	end
	
	it "should show delete links for comments" do
	  get :index, :insult_id => @insult.id
	  response.should have_selector("a", :content => "Delete",
					     :href => "/comments/#{@comment.id}",
					     :"data-method" => "delete")
	end
      end
    end	
  end
    
  describe "GET 'new'" do
    
    describe "access control" do
      
      it "should deny access to non-signed in users" do
	get :new, :insult_id => @insult
	response.should redirect_to(signin_path)
      end
    end
    
    describe "if signed in" do
      
      before(:each) do
	test_sign_in(@insulter)
      end
      
      it "should be succesful" do
	get :new, :insult_id => @insult
	response.should be_success
      end
    end
  end
  
  describe "POST 'create'" do
    
    describe "when not signed in" do
      
      it "should redirect to the login page" do
	post :create, :insult_id => @insult.id, :comment => { :content => "Foo bar" }
	response.should redirect_to(signin_path)
      end
      
      it "should not create a new comment" do
	lambda do
	  post :create, :insult_id => @insult.id, :comment => { :content => "Foo bar" }
	end.should_not change(Comment, :count)
      end
    end
    
    describe "failure" do
      
      before(:each) do
	test_sign_in(@insulter)
	@attr = { :content => "" } 
      end
      
      it "should not create a new comment" do
	lambda do
	  post :create, :insult_id => @insult.id, :comment => @attr
	end.should_not change(Comment, :count)
      end
      
      it "should render the comments/new page with a flash error message" do
	post :create, :insult_id => @insult.id, :comment => @attr
	flash[:error].should =~ /The comment could not be added./
	response.should render_template('comments/new')
      end
    end
    
    describe "success" do
      
      before(:each) do
	test_sign_in(@insulter)
	@attr = { :content => "Foo bar" }
      end
      
      it "should create a new comment" do
	lambda do
	  post :create, :insult_id => @insult.id, :comment => @attr
	end.should change(Comment, :count).by(1)
      end
      
      it "should have the right attributes" do
	post :create, :insult_id => @insult.id, :comment => @attr
	Comment.last.commenter_id.should == @insulter.id
	Comment.last.insult_id.should == @insult.id
	Comment.last.content.should == @attr[:content]
      end
      
      it "should redirect to the current insults' insult_comments_path last page" do
	post :create, :insult_id => @insult.id, :comment => @attr
	flash[:success].should =~ /Comment added!/
	pageno = Comment.count(:conditions => { :insult_id => @insult.id })
	response.should redirect_to(insult_comments_path(@insult, :page => pageno))
      end
    end
  end
  
  describe "DELETE 'destroy'" do
    
    before(:each) do
      @comment = Factory(:comment, :insult => @insult, :commenter => @insulter)
    end
    
    describe "access control" do
      
      it "should deny access to non-signed in users" do
	lambda do
	  delete :destroy, :id => @comment
	end.should_not change(Comment, :count)
	response.should redirect_to signin_path
      end
      
      it "should deny access to users that are not involved with the comment" do
	@third_user = Factory(:user, :username => Factory.next(:username),
				     :email => Factory.next(:email))
	test_sign_in(@third_user)
	lambda do
	  delete :destroy, :id => @comment
	end.should_not change(Comment, :count)
	response.should redirect_to(root_path)
      end
      
      it "should allow access to users that are insulted by the insult to which the comment belongs" do
	test_sign_in(@insulted)
	lambda do
	  delete :destroy, :id => @comment
	end.should change(Comment, :count).by(-1)
      end
      
      it "should not allow access to users that are the insulters of the insult to which the comment belongs" do
	@new_insulter = Factory(:user, :username => Factory.next(:username),
				       :email => Factory.next(:email))
	@new_insult = Factory(:insult, :insulter => @new_insulter, :insulted => @insulted)
	@new_comment = Factory(:comment, :insult => @new_insult, :commenter => @insulter)
	test_sign_in(@new_insulter)
	lambda do
	  delete :destroy, :id => @new_comment
	end.should_not change(Comment, :count)
	response.should redirect_to(root_path)
      end
      
      it "should allow access to users that left the comment" do
	test_sign_in(@insulter)
	lambda do
	  delete :destroy, :id => @comment
	end.should change(Comment, :count).by(-1)
      end
      
      it "should allow access to admin users" do
	@admin_user = test_sign_in(Factory(:user, :username => Factory.next(:username),
						  :email => Factory.next(:email),
						  :admin => true))
	lambda do
	  delete :destroy, :id => @comment
	end.should change(Comment, :count).by(-1)
      end
    end
    
    describe "success" do
      
      before(:each) do
	test_sign_in(@insulted)
      end
      
      it "should delete the comment" do
	lambda do
	  delete :destroy, :id => @comment
	end.should change(Comment, :count).by(-1)
	Comment.find_by_id(@comment.id).should be_nil
      end
      
      it "should show a flash success message" do
	delete :destroy, :id => @comment
	flash[:success].should =~ /Comment deleted./
      end
      
      it "should redirect to the insults' insult_comments_path" do
	delete :destroy, :id => @comment
	response.should redirect_to(insult_comments_path(@insult))
      end
    end
  end
end