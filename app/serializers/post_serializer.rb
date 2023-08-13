class PostSerializer < Blueprinter::Base
  identifier :id
  fields :title, :text
  field :category_id, name: :category
  field :comments_count

  association :comments, blueprint: CommentSerializer
  # attachment :picture

  field :picture_url do |post|
    Rails.application.routes.url_helpers.rails_blob_url(post.picture) if post.picture.attached?
  end

end