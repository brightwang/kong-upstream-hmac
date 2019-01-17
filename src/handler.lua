local BasePlugin = require "kong.plugins.base_plugin"
local req_set_header = ngx.req.set_header
local access = require "kong.plugins.kong-upstream-hmac.access"


local UpstreamHMACHandler = BasePlugin:extend()

function UpstreamHMACHandler:new()
    UpstreamHMACHandler.super.new(self, "kong-upstream-hmac")
end

function UpstreamHMACHandler:access(conf)
    UpstreamHMACHandler.super.access(self)
    access.execute(conf)
end

UpstreamHMACHandler.PRIORITY = 699

return UpstreamHMACHandler
