source 'https://rubygems.org'

# Specify your gem's dependencies in kml_agent.gemspec
gemspec

group :test, :development do
  gem 'jazz_hands', github: 'nixme/jazz_hands', branch: 'bring-your-own-debugger'
  gem 'pry-byebug'
end

group :test do
  gem 'cucumber-rails', '1.4.2'
  gem 'faker', '1.4.3'
  gem 'aws-sdk-v1', '~> 1.60.2'
  gem 'aws-sdk', '~> 2.0.47'
  gem 'rspec-rails', '~> 3.2.1'
end
