class WallsController < ApplicationController
   
  def wall_of_fame
    @title = "Best burns and insults on the web - Spotty Mouth"
    @todays_users = User.rank_tally(
      { :start_at => 1.day.ago,
        :end_at => Time.now,
        :limit => 10,
      })
    # Send with exclusive scope to override default order By in Insult model
    @todays_insults = Insult.send(:with_exclusive_scope) { Insult.rank_tally(
      {
        :start_at => 1.day.ago,
        :end_at => Time.now,
        :limit => 10,
        :conditions => nil
      }) }
    @all_time_users = User.rank_tally(
      {
	:limit => 10
      })
    # Send with exclusive scope to override default order By in Insult model
    @all_time_insults = Insult.send(:with_exclusive_scope) { Insult.rank_tally(
      {
	:limit => 10
      }) }
    
    @adjective = "Best"
    render 'wall'
  end
  
  def wall_of_shame
    @title = "Worst burns and insults on the web - Spotty Mouth"
    @todays_users = User.rank_tally(
      { :start_at => 1.day.ago,
        :end_at => Time.now,
        :limit => 10,
        :ascending => true
      })
     # Send with exclusive scope to override default order By in Insult model
    @todays_insults = Insult.send(:with_exclusive_scope) { Insult.rank_tally(
      {
        :start_at => 1.day.ago,
        :end_at => Time.now,
        :limit => 10,
        :ascending => true
      }) }
    @all_time_users = User.rank_tally(
      {
	:limit => 10,
	:ascending => true
      })
     # Send with exclusive scope to override default order By in Insult model
    @all_time_insults = Insult.send(:with_exclusive_scope) { Insult.rank_tally(
      {
	:limit => 10,
	:ascending => true
      }) }
    
    @adjective = "Worst"
    render 'wall'
  end
  
end
