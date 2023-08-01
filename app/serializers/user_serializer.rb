class UserSerializer < Blueprinter::Base
  identifier :id
  fields :name, :posts_count
  field :created_at, name: :registered_at

  view :with_posts_and_comments do
    association :posts, blueprint: PostSerializer
  end

end
