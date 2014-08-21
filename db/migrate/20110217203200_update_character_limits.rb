class UpdateCharacterLimits < ActiveRecord::Migration
  def self.up
    change_column :users, :username, :string, :limit => 30
  end

  def self.down
    change_column :users, :username, :string, :limit => 255
  end
end
