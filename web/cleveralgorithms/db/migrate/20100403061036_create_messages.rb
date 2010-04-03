class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.text :msg
      t.references :algorithm
      t.string :section
      t.string :name
      t.string :email
      t.string :subject
      t.boolean :addressed, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
