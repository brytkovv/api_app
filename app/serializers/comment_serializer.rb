class CommentSerializer < Blueprinter::Base
  identifier :id
  fields :grade, :text, :created_at
  field :user_id, name: :author_id

end