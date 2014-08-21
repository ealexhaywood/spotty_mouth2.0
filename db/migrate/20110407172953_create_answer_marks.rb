class CreateAnswerMarks < ActiveRecord::Migration
  def self.up
    create_table :answer_marks do |t|
      t.integer :question_id
      t.integer :answer_id
      t.integer :user_id

      t.timestamps
    end
    add_index :answer_marks, :question_id
    add_index :answer_marks, :user_id
    add_index :answer_marks, :answer_id
    add_index :answer_marks, [:user_id, :question_id], :unique => true
    add_index :answer_marks, [:answer_id, :question_id], :unique => true
  end

  def self.down
    drop_table :answer_marks
  end
end
