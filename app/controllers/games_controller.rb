class GamesController < ApplicationController
  skip_before_action :authorize, only: %i[create index update]
  def create
    game = Game.create!(create_params)
    render json: game, status: :created
  end

  def index
    user = User.find_by(id: index_params[:user_id])
    my_games = Game.all.filter {|g|g.user_id == user.id}
    render json: my_games, status: :ok
  end

  def update
    game = Game.find_by(id: update_params[:id])
    puts game.calc_num_right
    game.update(num_right: game.calc_num_right)
    puts game.calc_score
    game.update(score: game.calc_score)
  end

  private

  def create_params
    params.permit(:user_id, :num_questions)
  end

  def index_params
    params.permit(:user_id)
  end

  def update_params
    params.permit(:id, :num_right)
  end
end
