class CreateAlgorithms < ActiveRecord::Migration
  def self.up
    create_table :algorithms do |t|
      t.string :name
      t.text :aliases
      t.text :taxonomy
      t.text :inspiration
      t.text :metaphor
      t.text :strategy
      t.text :procedure
      t.text :heuristics
      t.text :code
      t.string :code_file
      t.text :references
      t.text :bibliography
      t.text :web
      t.boolean :released, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :algorithms
  end
end
