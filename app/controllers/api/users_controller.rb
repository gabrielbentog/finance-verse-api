class Api::UsersController < Api::ApiController
  before_action :set_user, only: [:show, :update, :destroy]
  skip_after_action :update_auth_header, only: [:destroy]
  skip_before_action :authenticate_api_user!, only: [:create]

  def index
    users = User.all.apply_filters(params)
    render json: users, each_serializer: UserSerializer, meta: generate_meta(users), status: :ok
  end

  def show
    render json: @user, serializer: UserSerializer
  end

  def create
    user = User.new(user_params)

    if user.save
      auth_token = user.create_new_auth_token
      response.headers.merge!(auth_token)
      render json: user, serializer: UserSerializer, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: @user, serializer: UserSerializer
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @user.destroy
    DeviseTokenAuth::Concerns::SetUserByToken.send(:define_method, :update_auth_header) { } if @user == current_api_user

    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar)
  end
end
