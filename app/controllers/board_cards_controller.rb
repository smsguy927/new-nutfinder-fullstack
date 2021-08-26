class BoardCardsController < ApplicationController
  skip_before_action :authorize, only: :create

  def create
    board_card = BoardCard.create!(create_params)
    render json: board_card, status: :created
  end

  private

  def create_params
    params.permit(:question_id, :card_id)
  end
end
