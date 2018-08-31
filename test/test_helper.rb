ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

require 'webmock/minitest'
WebMock.disable_net_connect!(allow_localhost: true)

require 'fake_upstream_service'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  setup do
    stub_request(:get, Addressable::Template.new("#{ENV['UPSTREAM_URI_ROOT']}{/name}")).to_rack(FakeUpstreamService)
    stub_request(:get, "#{ENV['UPSTREAM_URI_ROOT']}/timeout").to_timeout
  end
end
