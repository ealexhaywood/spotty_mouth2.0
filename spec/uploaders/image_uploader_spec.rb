require 'spec_helper'
require 'carrierwave/test/matchers'

describe ImageUploader do
  include CarrierWave::Test::Matchers

  before(:each) do
    @user = Factory(:user)
    @old_image = @user.image.url
    ImageUploader.enable_processing = true
    @uploader = ImageUploader.new(@user, :image)
    @uploader.store!(File.open('public/images/fallback/default.png'))
  end

  after(:each) do
    @uploader.remove!
    ImageUploader.enable_processing = false
  end

  it "should resize the image to no largen than 50x50 pixels" do
    @uploader.should be_no_larger_than(50, 50)
  end
end
