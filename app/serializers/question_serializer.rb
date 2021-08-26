class QuestionSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :question_num, :cards, :user_choice, :answer, :is_right
end
