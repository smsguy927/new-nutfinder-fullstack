class SessionsController < ApplicationController
  skip_before_action :authorize, only: %i[create destroy]

  def create
    user = User.find_by(username: params[:username])
    puts params[:password_reset_token]
    puts user.password_reset_token
    if user&.authenticate(params[:password]) || matching_password_token?(user)
      session[:user_id] = user.id
      user.update(password_reset_token: nil)
      render json: user
    elsif user.nil?
      render json: { errors: ['Username Does not Exist'] }, status: :unauthorized
    elsif params[:password].size.positive?
      render json: { errors: ['Invalid Password'] }, status: :unauthorized
    elsif params[:password_reset_token].size.positive?
      render json: { errors: ['That access code is invalid'] }, status: :unauthorized
    else
      render json: { errors: ['Login Failed'] }, status: :unauthorized
    end
  end

  def destroy
    session.delete :user_id
    head :no_content
  end

  def get_current_user
    if logged_in?
      render json: current_user
    end
  end
  
  private
  
  def matching_password_token?(user)
    params[:password_reset_token] == user.password_reset_token # && valid_password_token(user)
  end

  def valid_password_token(user)
    !user[:password_reset_token].nil? && user.password_token_valid?
  end
end
