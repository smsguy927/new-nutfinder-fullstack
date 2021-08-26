class CreateGameInstances < ActiveRecord::Migration[6.1]
  def change
    create_table :game_instances do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.integer :num_questions
      t.integer :num_right
      t.integer :score
      t.timestamps
    end
  end
end
