class CommentsController < ApplicationController

  def create
    post = Post.find(params[:post_id])
    comment = post.comments.build(comment_params)

    if comment.save
      render json: CommentSerializer.render(comment), status: :created
    else
      render json: { errors: comment.errors }, status: :unprocessable_entity
    end
  end

  def update
    comment = Comment.find(params[:id])
    if comment.update(comment_params)
      render json: CommentSerializer.render(comment)
    else
      render json: { errors: comment.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    head :no_content

  end

  private

  def comment_params
    params.require(:comment).permit(:grade, :text, :user_id)
  end

end
