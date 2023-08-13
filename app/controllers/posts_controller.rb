class PostsController < ApplicationController
  before_action :set_post, only: [:show, :update, :destroy]

  def create
    category = Category.find_by(key: params[:category_id])

    if category.nil?
      render json: { error: 'Category not found' }, status: :not_found
      return
    end

    post = category.posts.build(post_params)

    if post.save
      render json: PostSerializer.render(post), status: :created
    else
      render json: { errors: post.errors }, status: :unprocessable_entity
    end
  end

  def show
    render json: PostSerializer.render(@post)
  end

  def update
    if @post.update(post_params)
      render json: PostSerializer.render(@post)
    else
      render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    # @post.picture.purge # Удаление прикрепленного файла перед удалением поста
    @post.destroy
    head :no_content
  end

  private

  def post_params
    params.require(:post).permit(:title, :text, :user_id, :image)
  end

  def set_post
    @post = Post.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Post not found' }, status: :not_found
  end

end

