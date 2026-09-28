# Documented in docs/API.md. Limits are per IP for reads and per token for writes.
class Rack::Attack
  safelist("health") { |req| req.path == "/up" }

  throttle("api/reads", limit: 600, period: 1.minute) do |req|
    req.ip if req.path.start_with?("/api/") && req.get?
  end

  throttle("api/writes", limit: 120, period: 1.minute) do |req|
    next unless req.path.start_with?("/api/")
    next if req.get? || req.head?

    req.get_header("HTTP_AUTHORIZATION").presence || req.ip
  end

  throttle("html/signup", limit: 10, period: 1.hour) do |req|
    req.ip if req.post? && req.path == "/signup"
  end

  self.throttled_responder = lambda do |request|
    message = "Rate limit exceeded. Limits are listed at /docs/api."
    if request.path.start_with?("/api/")
      [ 429, { "Content-Type" => "application/json" }, [ { error: message }.to_json ] ]
    else
      [ 429, { "Content-Type" => "text/plain" }, [ message ] ]
    end
  end
end
