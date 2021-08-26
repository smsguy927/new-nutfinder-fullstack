class Add < ActiveRecord::Migration[6.1]
  def change
    add_column(:questions, :is_right, :boolean )
  end
end
