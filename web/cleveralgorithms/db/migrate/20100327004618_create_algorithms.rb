class CreateAlgorithms < ActiveRecord::Migration
  def self.up
    create_table :algorithms do |t|
      t.string :name
      t.text :aliases, :default => "N/A"
      t.text :taxonomy, :default => "N/A"
      t.text :inspiration, :default => "N/A"
      t.text :metaphor, :default => "N/A"
      t.text :strategy, :default => "N/A"
      t.text :procedure, :default => "N/A"
      t.text :heuristics, :default => "N/A"
      t.text :code, :default => "N/A"
      t.string :code_file, :default => "N/A"
      t.text :references, :default => "N/A"
      t.text :bibliography, :default => "N/A"
      t.text :web, :default => "N/A"
      t.boolean :released, :default => 0
      
      t.timestamps
    end
  end

  def self.down
    drop_table :algorithms
  end
end
