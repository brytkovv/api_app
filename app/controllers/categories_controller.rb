class CategoriesController < ApplicationController
  before_action :set_category, only: [:update, :destroy]

  def index
    categories = Category.all
    render json: CategorySerializer.render(categories)
  end

  def create
    category = Category.new(category_params)
    if category.save
      render json: CategorySerializer.render(category), status: :created
    else
      render json: { errors: category.errors }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: CategorySerializer.render(@category)
    else
      render json: { errors: @category.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    head :no_content
  end

  private

  def set_category
    @category = Category.find(params[:id])
  end

  def category_params
    params.require(:category).permit(:key, :name, :description)
  end

end
