class Post < ApplicationRecord
  belongs_to :category, foreign_key: :category_id, primary_key: :key
  belongs_to :user
  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :text, presence: true

  has_one_attached :picture, dependent: :destroy#, optional: true

  after_create :increment_count
  after_destroy :decrement_count
  # after_commit :decrement_count, on: [:destroy] # TODO: разорбраться

  def increment_count
    parent = user

    while parent.is_a? Post
      parent = parent.user
    end
    parent.increment! :posts_count

    # parent = user.ancestors.find { |ancestor| ancestor.is_a?(User) }
    # parent.increment!(:posts_count) # TODO: изменить здесь и в комментах
  end

  def decrement_count
    parent = user

    while parent.is_a? Post
      parent = parent.user
    end
    parent.decrement! :posts_count
  end

end
