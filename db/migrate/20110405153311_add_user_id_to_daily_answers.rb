class AddUserIdToDailyAnswers < ActiveRecord::Migration
  def self.up
    add_column :daily_answers, :user_id, :integer
  end

  def self.down
    remove_column :daily_answers, :user_id
  end
end
