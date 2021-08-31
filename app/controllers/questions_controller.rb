

require_relative '../models/board_internal'
require_relative '../models/card_internal'

class QuestionsController < ApplicationController
  skip_before_action :authorize, only: %i[create show update]
  CARD_SEP = '_'.freeze
  COMBO_SEP = '__'.freeze

  def create
    question = Question.create!(create_params)

    internal_board = BoardInternal.new
    internal_board.make_board_with(question.cards.split(CARD_SEP))
    question.update(answer: internal_board.nut_combos.join(''))
    puts question.answer
    render json: question, status: :created
  end

  def show
    game = Game.find_by(id: show_params[:id])
    my_questions = Question.all.filter {|q| q.game_id == game.id}
    render json: my_questions, status: :ok
  end

  def update
    question = Question.find_by(id: update_params[:id])
    question.update(user_choice: update_params[:user_choice])

    puts "UC: #{question.user_choice}"
    question.update(is_right: question.correct_answer?)
    puts question.correct_answer?
    render json: question, status: :ok
  end

  private

  def create_params
    params.permit(:game_id, :question_num, :cards)
  end

  def show_params
    params.permit(:id)
  end

  def update_params
    params.permit(:id, :user_choice)
  end
end
