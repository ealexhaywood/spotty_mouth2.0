require 'spec_helper'

describe WallsController do
  render_views
  
  describe "GET 'walloffame" do
    
    before(:each) do
      @user = Factory(:user)
      @insulted = Factory(:user, :username => Factory.next(:username),
				 :email => Factory.next(:email))
      @insult = Factory(:insult, :insulter => @user, :insulted => @insulted)
    end
    
    it "should be successful" do
      get :wall_of_fame
      response.should be_success
    end
    
    it "should have the right title" do
      get :wall_of_fame
      response.should have_selector("title", 
                                    :content => "Best burns and insults on the web - Spotty Mouth")
    end
    
    it "should not render users with no votes" do
      get :wall_of_fame
      response.should_not have_selector("a", :content => @user.username,
					     :href => user_path(@user))
    end
    
    it "should only render the top 10 users at a time" do
      10.times do
	@other_user = Factory(:user, :username => Factory.next(:username),
				   :email => Factory.next(:email))
	@user.vote_for(@other_user)
	@other_user.vote_against(@user)
      end  
      get :wall_of_fame
      response.should have_selector("a", :content => @other_user.username,
					     :href => user_path(@other_user))
      response.should_not have_selector("a", :content => @user.username,
					     :href => user_path(@user))
    end
    
    it "should not render insults with no votes" do
      get :wall_of_fame
      response.should_not have_selector("div.insult_info")
    end
    
    it "should only show the first 30 characters of the insult" do
      @user.vote_for(@insult)
      @insult.update_attribute(:content, "a" * 31)
      get :wall_of_fame
      response.should have_selector("td", :content => "#{@insult.content[0,30]}")
      response.should_not have_selector("td", :content => "#{@insult.content[0,31]}")
    end
    
    it "should only render the top 10 insults at a time" do
      @user.vote_against(@insult)
      10.times do
	@new_insult = Factory(:insult, :insulter => @user, :insulted => @insulted,
				       :content => Factory.next(:content))
	@user.vote_for(@new_insult)
      end
      get :wall_of_fame
      response.should have_selector("td", :content => "#{@new_insult.content[0,30]}")
      response.should_not have_selector("td", :content => "#{@insult.content[0,30]}")
    end
    
    it "should have links to the users' insult index, voters_for page, and voters_against pages" do
      @insulted.vote_for(@user)
      get :wall_of_fame
      response.should have_selector("a", :content => "#{Insult.where(:insulter_id => @user).count} insult",
					 :href => user_insults_path(@user))
      response.should have_selector("a", :content => "#{@user.votes_for} vote for",
					 :href => voters_for_user_path(@user))
      response.should have_selector("a", :content => "#{@user.votes_against} votes against",
					 :href => voters_against_user_path(@user))
    end
    
    it "should have links to the insults' voters_for page and voters_against pages" do
      @user.vote_for(@insult)
      get :wall_of_fame
      response.should have_selector("a", :content => "#{@insult.votes_for} vote for",
					 :href => voters_for_insult_path(@insult))
      response.should have_selector("a", :content => "#{@insult.votes_against} votes against",
					 :href => voters_against_insult_path(@insult))
    end
  end

  describe "GET 'wallofshame'" do
    
   before(:each) do
      @user = Factory(:user)
      @insulted = Factory(:user, :username => Factory.next(:username),
				 :email => Factory.next(:email))
      @insult = Factory(:insult, :insulter => @user, :insulted => @insulted)
    end
    
    it "should be successful" do
      get :wall_of_shame
      response.should be_success
    end
    
    it "should have the right title" do
      get :wall_of_shame
      response.should have_selector("title", 
                                    :content => "Worst burns and insults on the web - Spotty Mouth")
    end
    
     it "should not render users with no votes" do
      get :wall_of_shame
      response.should_not have_selector("a", :content => @user.username,
					     :href => user_path(@user))
    end
    
    it "should only render the bottom 10 users at a time" do
      10.times do
	@other_user = Factory(:user, :username => Factory.next(:username),
				   :email => Factory.next(:email))
	@user.vote_against(@other_user)
	@other_user.vote_for(@user)
      end  
      get :wall_of_shame
      response.should have_selector("a", :content => @other_user.username,
					     :href => user_path(@other_user))
      response.should_not have_selector("a", :content => @user.username,
					     :href => user_path(@user))
    end
    
    it "should not render insults with no votes" do
      get :wall_of_shame
      response.should_not have_selector("div.insult_info")
    end
    
    it "should only show the first 30 characters of the insult" do
      @user.vote_against(@insult)
      @insult.update_attribute(:content, "a" * 31)
      get :wall_of_shame
      response.should have_selector("td", :content => "#{@insult.content[0,30]}")
      response.should_not have_selector("td", :content => "#{@insult.content[0,31]}")
    end
    
    it "should only render the bottom 10 insults at a time" do
      @user.vote_for(@insult)
      10.times do
	@new_insult = Factory(:insult, :insulter => @user, :insulted => @insulted,
				       :content => Factory.next(:content))
	@user.vote_against(@new_insult)
      end
      get :wall_of_shame
      response.should have_selector("td", :content => "#{@new_insult.content[0,30]}")
      response.should_not have_selector("td", :content => "#{@insult.content[0,30]}")
    end
    
    it "should have links to the users' insult index, voters_for page, and voters_against pages" do
      @insulted.vote_against(@user)
      get :wall_of_shame
      response.should have_selector("a", :content => "#{Insult.where(:insulter_id => @user).count} insult",
					 :href => user_insults_path(@user))
      response.should have_selector("a", :content => "#{@user.votes_for} votes for",
					 :href => voters_for_user_path(@user))
      response.should have_selector("a", :content => "#{@user.votes_against} vote against",
					 :href => voters_against_user_path(@user))
    end
    
    it "should have links to the insults' voters_for page and voters_against pages" do
      @user.vote_against(@insult)
      get :wall_of_shame
      response.should have_selector("a", :content => "#{@insult.votes_for} votes for",
					 :href => voters_for_insult_path(@insult))
      response.should have_selector("a", :content => "#{@insult.votes_against} vote against",
					 :href => voters_against_insult_path(@insult))
    end
  end
end
