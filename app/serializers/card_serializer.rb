class CardSerializer < ActiveModel::Serializer
  attributes :id, :card_id, :rank_id, :rank, :suit
end