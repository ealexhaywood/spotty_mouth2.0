require 'spec_helper'

describe UserNotifier do
include EmailSpec::Helpers
include EmailSpec::Matchers

  before(:each) do
    @user = Factory(:user)
    @random_password = "23048957fdsalujasdf"
    @email = UserNotifier.new_password(@user, @random_password).deliver
  end
  
  it "should deliver to the email address passed in" do
    @email.should deliver_to(@user.email)
  end
  
  it "should have the correct subject" do
    @email.should have_subject(/Your new password/)
  end
end