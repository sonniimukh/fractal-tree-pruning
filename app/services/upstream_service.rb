require 'http'
require 'addressable/template'

class UpstreamService

  def self.fetch_tree(name, attempt=1)

    uri = Addressable::Template
      .new("#{ENV['UPSTREAM_URI_ROOT']}{/name}")
      .expand({name: name})

    response = HTTP
      .timeout( 
        :global, 
        connect: ENV['UPSTREAM_TIMEOUT_CONNECT'].to_i, 
        write:   ENV['UPSTREAM_TIMEOUT_WRITE'].to_i, 
        read:    ENV['UPSTREAM_TIMEOUT_READ'].to_i)
      .get(uri)

    raise ApplicationExceptions::UpstreamNotFoundError, 'Wrong tree name'              if response.code==400
    raise ApplicationExceptions::UpstreamNotFoundError, 'Tree not found'               if response.code==404
    raise ApplicationExceptions::UpstreamServiceError,  'Internal: '+response.to_s  if response.code==500

    return JSON.parse(response.to_s)
    
  rescue JSON::ParserError, HTTP::ConnectionError, HTTP::TimeoutError, ApplicationExceptions::UpstreamServiceError => e
    
    if attempt < ENV['UPSTREAM_RETRIES'].to_i

      Rails.logger.warn "Upstream service error on attempt ##{attempt}, fetching \"#{name}\": #{e.message}"
      sleep ENV['UPSTREAM_RETRY_DELAY'].to_i
      return fetch_tree(name, attempt+1)

    else

      raise ApplicationExceptions::UpstreamServiceError, "Upstream service error: #{e.message}"

    end

  end

end