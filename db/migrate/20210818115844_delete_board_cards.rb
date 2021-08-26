class DeleteBoardCards < ActiveRecord::Migration[6.1]
  def change
    drop_table('board_cards')
  end
end
