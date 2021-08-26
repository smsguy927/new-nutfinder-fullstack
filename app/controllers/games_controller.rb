class GamesController < ApplicationController
  skip_before_action :authorize, only: :create
  def create
    game = Game.create!(create_params)
    render json: game, status: :created
  end

  private

  def create_params
    params.permit(:user_id, :num_questions)
  end
end
