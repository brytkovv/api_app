class PostSerializer < Blueprinter::Base
  identifier :id
  fields :title, :text
  field :category_id, name: :category
  field :comments_count

  association :comments, blueprint: CommentSerializer

end