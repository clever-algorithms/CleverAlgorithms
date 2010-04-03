class CreateAlgorithms < ActiveRecord::Migration
  def self.up
    create_table :algorithms do |t|
      t.string :name
      t.text :aliases, :default => ""
      t.text :taxonomy, :default => ""
      t.text :inspiration, :default => ""
      t.text :metaphor, :default => ""
      t.text :strategy, :default => ""
      t.text :procedure, :default => ""
      t.text :heuristics, :default => ""
      t.text :code, :default => ""
      t.string :code_file, :default => ""
      t.text :references, :default => ""
      t.text :bibliography, :default => ""
      t.text :web, :default => ""
      t.boolean :released, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :algorithms
  end
end
