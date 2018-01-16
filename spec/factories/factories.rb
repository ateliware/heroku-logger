FactoryBot.define do
  factory :log do
    host "example.com"
    path "/test"
    http_method { %w(get post put delete).sample }
    status { 200 }
    fwd { Faker::Internet.public_ip_v4_address }
    created_at { Time.current }
    timestamp { Time.current - rand(10).days }
    request_id { Faker::Internet.ip_v6_address }
  end

  factory :log_parser, class: Log::Parser do
    raw_log '184 <158>1 2018-01-11T00:14:32.564740+00:00 host heroku router - at=info method=GET path="/assets/application-80d996eab4414b4f5a1d73e71398100044e85130563592358fa235e0ef5e1a91.css" host=www.vestibulandoonline.com request_id=3a42372d-7a30-425d-9e84-b91a56caaf13 fwd="10.20.1.1,35.199.86.183" dyno=web.1 connect=0ms service=16ms status=200 bytes=45552 protocol=http'
  end
end
