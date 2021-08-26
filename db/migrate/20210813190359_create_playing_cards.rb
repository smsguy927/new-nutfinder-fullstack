class CreatePlayingCards < ActiveRecord::Migration[6.1]
  def change
    create_table :playing_cards do |t|
      t.integer :card_id
      t.integer :rank_id
      t.string :rank
      t.string :suit
    end
  end
end
