module ApplicationExceptions
  class UpstreamServiceError < StandardError; end
  class UpstreamNotFoundError < StandardError; end
end