# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

Sidekiq::Extensions.enable_delay!
