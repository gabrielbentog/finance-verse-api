# config/initializers/rack_attack.rb

class Rack::Attack

  ### 🚫 Throttle por IP (5 tentativas de login a cada 20 segundos)
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/api/authenticate" && req.post?
      req.ip
    end
  end

  ### ❌ Block IPs maliciosos conhecidos (exemplo)
  blocklist("block 1.2.3.4") do |req|
    "1.2.3.4" == req.ip
  end

  ### ✅ Permitir localhost e serviços internos (whitelist)
  safelist("allow localhost") do |req|
    ['127.0.0.1', '::1'].include?(req.ip)
  end

  ### 📊 Log para ver o que está sendo bloqueado
  ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
    req = payload[:request]
    Rails.logger.info "[Rack::Attack] Blocked #{req.ip} on #{req.path}"
  end
end
