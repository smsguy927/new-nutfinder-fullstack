class AnswerCard < ActiveRecord::Migration[6.1]
  def change
    create_table :answer_cards do |t|
      t.belongs_to :question, null: false, foreign_key: true
      t.belongs_to :card, null: false, foreign_key: true

      t.integer :combo_num, null: false
      t.boolean :any_rank, null: false
      t.boolean :any_suit, null: false

      t.timestamps
    end
  end
end
