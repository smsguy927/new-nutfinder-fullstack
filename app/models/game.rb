# frozen_string_literal: true
class Game < ApplicationRecord
  POINTS_PER_QUESTION = 100
  def calc_num_right
    Question.all.filter{ |q| q.game_id == id && q.is_right == true }.size
  end

  def calc_score
    POINTS_PER_QUESTION * num_right * num_right / num_questions
  end
end
