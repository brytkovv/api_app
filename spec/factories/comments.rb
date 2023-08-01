FactoryBot.define do
  factory :comment do
    grade { rand(1..5) }
    text { Faker::Movies::HarryPotter.quote }

    association :user
    association :post

  end
end
