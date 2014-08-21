class AddBlurbToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :blurb, :string, :limit => 600
  end

  def self.down
    remove_column :users, :blurb
  end
end
