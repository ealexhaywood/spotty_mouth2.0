class PagesController < ApplicationController
  
  def home
    if signed_in?
      @feed_items = current_user.feed.paginate(:page => params[:page])
    end
  end
  
  def contact
    @title = "Best insults the internet has to offer - Spotty Mouth"
  end
  
  def find_victim
    @title = "Make fun of a hater - Spotty Mouth Search"
    if params[:search].nil? || params[:search].blank?
      @newest_users = User.order("id DESC").limit(15)
    else
      @search_users = User.where('LOWER(username) LIKE ?', "%#{params[:search].downcase}%").
			paginate(:page => params[:page])
    end
  end
  
  def terms_and_conditions
    @title = "Spotty Mouth Terms & Conditions"
  end
end
