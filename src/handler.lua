local access = require "kong.plugins.kong-upstream-hmac.access"

local UpstreamHMACHandler = {
  VERSION = "2.0.0-1",
  PRIORITY = 666,
}

function UpstreamHMACHandler:access(conf)
  access.execute(conf)
end

return UpstreamHMACHandler
