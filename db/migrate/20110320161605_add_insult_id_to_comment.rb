class AddInsultIdToComment < ActiveRecord::Migration
  def self.up
    add_column :comments, :insult_id, :integer
  end

  def self.down
    remove_column :comments, :insult_id
  end
end
