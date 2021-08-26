# frozen_string_literal: true

class AddPointsToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :points, :integer, default: 200
  end
end
