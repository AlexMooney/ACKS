ENV["RAILS_ENV"] ||= "test"
ENV["COLUMNS"] ||= "200" # TTY::Screen uses this for terminal width in tests
require_relative "../config/environment"
require "rails/test_help"
require "minitest/spec"

# TTY::Table calls $stdout.ioctl to detect terminal width, but capture_io
# redirects $stdout to a StringIO which doesn't have ioctl.
class StringIO
  def ioctl(*)
    80
  end
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
