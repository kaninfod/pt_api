
class API::UsersController < ApplicationController
  skip_before_action :authenticate_request, only: :authenticate

  def authenticate
    command = AuthenticateUser.call(params[:email], params[:password])

    if command.success?
      @user = User.find_by_email(params[:email])
      @user.update(remember_token: command.result)
      render json: @user
      # render json: { status: 200, auth_token: command.result, user: user }
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end

  def validate_token
    @current_user = AuthorizeApiRequest.call(request.headers).result
    if @current_user
      render json: @current_user
    else
      render json: { error: 'Not Authorized' }, status: 401
    end
  end
end
