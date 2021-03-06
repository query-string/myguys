ENV["RAILS_ENV"] = "test"

require File.expand_path("../../config/environment", __FILE__)

require "rspec/rails"
require "shoulda/matchers"

Dir[Rails.root.join("spec/support/**/*.rb")].each { |file| require file }
ActiveSupport::Dependencies.autoload_paths << Rails.root.join("spec/pages")

RSpec.configure do |config|
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.use_transactional_fixtures = false
  config.raise_errors_for_deprecations!

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
  end
end

ActiveRecord::Migration.maintain_test_schema!
require 'capybara/poltergeist'
Capybara.javascript_driver = :poltergeist

