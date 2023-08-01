class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  validates :text, presence: true
  validates :grade, numericality:
    { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  after_create :increment_count
  after_destroy :decrement_count

  def increment_count
    parent = post

    while parent.is_a? Comment
      parent = parent.post
    end
    parent.increment! :comments_count
  end

  def decrement_count
    parent = post

    while parent.is_a? Comment
      parent = parent.post
    end
    parent.decrement! :comments_count
  end

end
