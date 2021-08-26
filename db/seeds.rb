# # This file should contain all the record creation needed to seed the database with its default values.
# # The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
# #
# # Examples:
# #
# #   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
# #   Character.create(name: 'Luke', movie: movies.first)
Card.destroy_all
Article.destroy_all
# User.destroy_all
Game.destroy_all
ActiveRecord::Base.connection.reset_pk_sequence!('playing_cards')
OFFSET = 1
MIN_RANK_ID = 2
MAX_RANK_ID = 14
MIN_SUIT_INDEX = 0
MAX_SUIT_INDEX = 3
MULTIPLIER = 13
RANKS = %w[2 3 4 5 6 7 8 9 T J Q K A].freeze
SUITS = %w[d c h s].freeze
def make_deck
  (MIN_SUIT_INDEX..MAX_SUIT_INDEX).each do |i|
    (MIN_RANK_ID..MAX_RANK_ID).each do |j|
      card_id = MULTIPLIER * i + j - OFFSET
      rank_id = j
      rank = RANKS[j - MIN_RANK_ID]
      suit = SUITS[i]
      Card.create(card_id: card_id, rank_id: rank_id, rank: rank, suit: suit)
    end
  end
end
def make_users_and_articles
  5.times do
    user = User.create(username: Faker::GreekPhilosophers.name.downcase.gsub(/\W/, '_'))

    rand(3..5).times do
      user.articles.create(
        title: Faker::Lorem.sentence,
        content: Faker::Markdown.sandwich(sentences: rand(3..6), repeat: rand(2..5)),
        minutes_to_read: rand(3..50)
      )
    end
  end
end
make_deck




puts 'Done Seeding!'

