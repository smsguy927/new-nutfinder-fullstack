class GameSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :num_questions, :num_right, :score
end