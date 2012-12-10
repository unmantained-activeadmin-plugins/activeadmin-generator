Airbrake.configure do |config|
  config.api_key = "<%= @api_key %>"
  config.host    = "<%= @errbit_host %>"
  config.port    = <%= @errbit_port %>
  config.secure  = config.port == 443
end
