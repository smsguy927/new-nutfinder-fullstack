class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.string :cards
      t.string :user_choice
      t.string :answer
      t.timestamps
    end
  end
end
