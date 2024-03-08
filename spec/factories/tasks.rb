FactoryBot.define do
  factory :task do
    title { "MyString" }
    description { "MyText" }
    due_date { "2024-03-07" }
    completed_date { "2024-03-07" }
    progress { "9.99" }
    status { 1 }
    priority { 1 }
    user { nil }
  end
end
