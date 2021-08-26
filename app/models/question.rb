# frozen_string_literal: true

class Question < ApplicationRecord
  ANY_RANK = 'X'
  ANY_SUIT = 'x'
  CARD_SEP = '_'
  COMBO_SEP = '__'
  COMBO_SIZE = 5
  RANK = 0
  SUIT = 1
  FIRST = 0
  SECOND = 1

  def match_rank?(choice, answer)
    answer == ANY_RANK || choice == answer
  end

  def match_suit?(choice, answer)
    answer == ANY_SUIT || choice == answer
  end

  def match_card?(choice, answer)
    match_rank?(choice[RANK], answer[RANK]) && match_suit?(choice[SUIT], answer[SUIT])
  end

  def match_combo?(choice, answer)
    match_card?(choice[FIRST], answer[FIRST]) && match_card?(choice[SECOND], answer[SECOND])
  end

  def correct_answer?
    puts "User Choice: #{self.user_choice}"
    puts "Answer: #{self.answer}"
    answer_combo_arr = answer.split(COMBO_SEP)
    answer_combo_arr = answer_combo_arr.map { |str| str.split(CARD_SEP) }
    user_choice_arr = user_choice.split(CARD_SEP)
    return true if answer_combo_arr.any? { |combo| match_combo?(user_choice_arr, combo) }

    user_choice_arr.reverse!
    answer_combo_arr.any? { |combo| match_combo?(user_choice_arr, combo) }
  end

end
