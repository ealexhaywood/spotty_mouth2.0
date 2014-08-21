class CreateDailyQuestions < ActiveRecord::Migration
  def self.up
    create_table :daily_questions do |t|
      t.string :content

      t.timestamps
    end
  end

  def self.down
    drop_table :daily_questions
  end
end
