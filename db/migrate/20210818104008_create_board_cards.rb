class CreateBoardCards < ActiveRecord::Migration[6.1]
  def change
    create_table :board_cards do |t|
      t.belongs_to :question, null: false, foreign_key: true
      t.belongs_to :playing_card, null: false, foreign_key: true

      t.timestamps
    end
  end
end
