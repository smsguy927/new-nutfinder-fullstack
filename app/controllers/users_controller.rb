# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authorize, only: %i[create update]

  def create
    user = User.create!(create_params)
    session[:user_id] = user.id
    render json: user, status: :created
  end

  def update
    puts update_params[:id]
    user = User.find_by(id: update_params[:id])
    user.update(password: update_params[:password])
    user.update(password_confirmation: update_params[:password_confirmation])


    render json: user, status: :ok
  end

  def show
    render json: @current_user
  end

  def create_params
    params.permit(:first_name, :last_name, :username, :password, :password_confirmation, :email, :created_at, :points)
  end

  def update_params
    params.permit(:id, :password, :password_confirmation)
  end
end
