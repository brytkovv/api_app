existing_keys = Set.new  # TODO: можно лучше сделать
rand(14...40).times do
  unique_key = nil
  loop do
    unique_key = Faker::Hipster.word.capitalize
    break unless existing_keys.include?(unique_key)
  end

  existing_keys.add(unique_key)

  Category.create({
                    key: unique_key,
                    name: Faker::Hipster.word,
                    description: Faker::Lorem.sentence
                  })
end

rand(30...45).times do
  User.create!({
                name: Faker::Name.first_name,
              })
end

rand(50...75).times do
  Post.create!({
                 title: Faker::Creature::Animal.name,
                 text: Faker::Movies::HarryPotter.quote,
                 category_id: Category.pluck(:key).sample,
                 user_id: User.pluck(:id).sample
               })
end

rand(75...100).times do
  Comment.create!({
                   grade: rand(1...5),
                   text: Faker::Movies::HarryPotter.quote,
                   user_id: User.pluck(:id).sample,
                   post_id: Post.pluck(:id).sample
                 })
end

