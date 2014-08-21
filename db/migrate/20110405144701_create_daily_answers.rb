class CreateDailyAnswers < ActiveRecord::Migration
  def self.up
    create_table :daily_answers do |t|
      t.string :content
      t.integer :daily_question_id

      t.timestamps
    end
  end

  def self.down
    drop_table :daily_answers
  end
end
