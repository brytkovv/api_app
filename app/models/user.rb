class User < ApplicationRecord
  has_many :posts, dependent: :nullify
  has_many :comments, dependent: :destroy

  validates :name, presence: true

end
