class RenamePlayingCardToCard < ActiveRecord::Migration[6.1]
  def change
    rename_table :playing_cards, :cards
  end
end
