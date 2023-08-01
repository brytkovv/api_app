
class CategorySerializer < Blueprinter::Base
  identifier :key
  fields :name, :description

end