FactoryBot.define do
  factory :post do
    title { Faker::Creature::Animal.name }
    text { Faker::Movies::HarryPotter.quote }

    association :category
    association :user

  end
end
