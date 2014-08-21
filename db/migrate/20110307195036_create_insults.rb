class CreateInsults < ActiveRecord::Migration
  def self.up
    create_table :insults do |t|
      t.string :content
      t.integer :insulter_id
      t.integer :insulted_id

      t.timestamps
    end
    add_index :insults, :insulter_id
    add_index :insults, :insulted_id
  end

  def self.down
    drop_table :insults
  end
end
