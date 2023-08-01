class Post < ApplicationRecord
  belongs_to :category, foreign_key: :category_id, primary_key: :key
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :text, presence: true

  # has_one_attached :picture TODO: реализовать

  after_create :increment_count
  after_destroy :decrement_count

  def increment_count
    parent = user

    while parent.is_a? Post
      parent = parent.user
    end
    parent.increment! :posts_count
  end

  def decrement_count
    parent = user

    while parent.is_a? Post
      parent = parent.user
    end
    parent.decrement! :posts_count
  end

end
