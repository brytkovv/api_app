FactoryBot.define do
  factory :category do
    sequence(:key) { |n| "#{Faker::Hipster.word.capitalize}#{n}" }
    name { Faker::Hipster.word }
    description { Faker::Lorem.sentence }
  end
end
