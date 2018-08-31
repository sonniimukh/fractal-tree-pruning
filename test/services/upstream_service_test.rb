require 'test_helper'

class UpstreamServiceTest < ActiveSupport::TestCase
  
  test 'should get valid tree' do
    result = UpstreamService.fetch_tree('input')
    assert_equal result, JSON.parse(File.read(Rails.root.join("test/fixtures/trees/input.json" )))
  end

  test 'should raise UpstreamNotFoundError for invalid tree name' do
    assert_raises(ApplicationExceptions::UpstreamNotFoundError) {
      UpstreamService.fetch_tree('noname')
    }
    assert_raises(ApplicationExceptions::UpstreamNotFoundError) {
      UpstreamService.fetch_tree('%')
    }
  end

  test 'should raise UpstreamServiceError in case of repeated timeouts' do
    assert_raises(ApplicationExceptions::UpstreamServiceError) {
      UpstreamService.fetch_tree('timeout')
    }
  end

  test 'should raise UpstreamServiceError in case of "derper" sample error' do
    assert_raises(ApplicationExceptions::UpstreamServiceError) {
      UpstreamService.fetch_tree('derper')
    }
  end

  test 'should raise UpstreamServiceError in case non-JSON in upstream response' do
    assert_raises(ApplicationExceptions::UpstreamServiceError) {
      UpstreamService.fetch_tree('not-a-json')
    }
  end

  test 'should not exceed the set timeouts' do
    start = Time.now
    assert_raises(ApplicationExceptions::UpstreamServiceError) {
      UpstreamService.fetch_tree('timeout')
    }
    duration = Time.now - start

    timeout = ENV['UPSTREAM_TIMEOUT_CONNECT'].to_i + ENV['UPSTREAM_TIMEOUT_WRITE'].to_i + ENV['UPSTREAM_TIMEOUT_READ'].to_i
    retries = ENV['UPSTREAM_RETRIES'].to_i
    delay   = ENV['UPSTREAM_RETRY_DELAY'].to_i

    assert retries*timeout+(delay*(retries-1)) >= duration
  end

end
