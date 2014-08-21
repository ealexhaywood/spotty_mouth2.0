class AddAnswerMarkIdToDailyAnswers < ActiveRecord::Migration
  def self.up
    add_column :daily_answers, :answer_mark_id, :integer
    add_index :daily_answers, :answer_mark_id
  end

  def self.down
    remove_column :daily_answers, :answer_mark_id
  end
end
