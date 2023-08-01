class Category < ApplicationRecord
  self.primary_key = 'key'
  has_many :posts, dependent: :destroy

  validates :key, presence: true
  validates :name, presence: true
end
