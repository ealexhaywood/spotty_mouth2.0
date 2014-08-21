require 'spec_helper'

describe "AnswerMarks" do

  before(:each) do
    @user = Factory(:user)
    @other_user = Factory(:user, :username => Factory.next(:username),
			    :email => Factory.next(:email))
    @question = Factory(:daily_question)
    @answer1 = Factory(:daily_answer, :user => @other_user, :daily_question => @question)
    @am1 = Factory(:answer_mark, :answer_id => @answer1.id)
    integration_sign_in(@user)
  end
  
  describe "link_testing" do
    
    it "should correctly alter the answer_mark links" do
      click_link "Daily Question"
      save_and_open_page
      page.should have_selector("div", :class => "object_wrapper marked_answer",
					   :content => @answer1.content)
      page.should have_no_selector("a", :content => "Unmark")
      first_comment = "Here is the first comment"
      page.fill_in "daily_answer[content]", :with => first_comment
      click_button "Submit"
      page.should have_selector("div", :content => first_comment)
      da1 = DailyAnswer.find_by_content(first_comment)
      page.should have_selector("a", :content => "Mark as Answer",
					 :"data-method" => "post",
					 :href => answer_marks_path(:id => da1.id))
      click_link "Mark as Answer"
      page_should have_selector("a", :content => "Unmark")
      page_should have_selector("div", :class => "object_wrapper marked_answer",
					  :count => 2)
      second_comment = "Here is the second comment"
      page.fill_in "daily_answer_content", :with => second_comment
      click_button "Submit"
      page.should_not have_selector("a", :content => "Mark as Answer")
      click_link "Unmark"
      page.should have_selector("a", :content => "Mark as Answer",
					 :"data-method" => "post",
					 :count => 2)  
    end
  end
end
