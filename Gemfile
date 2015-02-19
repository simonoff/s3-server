source 'https://rubygems.org'


gem 'rails', '4.1.8'
gem 'sqlite3'
gem 'rack-cors', '0.2.9', require: 'rack/cors'
gem 'carrierwave', '0.10.0'
gem 'tilt', '1.4.1'

group :test, :development do
  gem 'jazz_hands', github: 'nixme/jazz_hands', branch: 'bring-your-own-debugger'
  gem 'pry-byebug'
  gem 'rspec-rails', '3.1.0'
end

group :development do
  gem 'spring'
  gem 'rubocop', '0.20.0'
end

group :test do
  gem 'cucumber-rails', '1.4.2'
  gem 'faker', '1.4.3'
  gem 'aws-sdk', '~> 1.60.2'
end

group :production do
  gem 'rake'
  gem 'puma', '2.9.1'
end
