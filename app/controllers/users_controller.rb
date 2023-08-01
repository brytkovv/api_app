class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]

  rescue_from ActiveRecord::RecordNotFound, with: :user_not_found

  def index
    cache_key = "users/#{params[:page]}/#{params[:created_after]}/#{params[:created_before]}"

    # Пытаемся получить данные из кэша
    users = Rails.cache.fetch(cache_key, expires_in: 1.minute) do
      # Если данных в кэше нет, выполняем запрос к базе данных и кэшируем результат
      users = User.order(:created_at)

      if params[:created_after].present?
        users = users.where('created_at >= ?', params[:created_after])
      end

      if params[:created_before].present?
        users = users.where('created_at <= ?', params[:created_before])
      end

      users.paginate(page: params[:page], per_page: 10)
    end

    # /users?page=2&created_after=2023-01-01&created_before=2023-07-30
    render json: UserSerializer.render(users)

  end

  def show
    render json: UserSerializer.render(@user, view: :with_posts_and_comments)
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: UserSerializer.render(user), status: :created
    else
      render json: { errors: user.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @user.update(user_params)
      render json: UserSerializer.render(@user)
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    user_comments = @user.comments
    user_comments.destroy_all
    user_comments.reload

    user_posts = @user.posts
    user_posts.update_all(user_id: nil)
    user_posts.reload

    @user.destroy
    head :no_content
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def user_params
    params.require(:user).permit(:name)
  end

end
