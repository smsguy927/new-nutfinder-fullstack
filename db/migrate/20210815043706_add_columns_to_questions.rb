class AddColumnsToQuestions < ActiveRecord::Migration[6.1]
  def change
    add_column(:questions, :game_id, :integer )
    add_column(:questions, :question_num, :integer )
  end
end
