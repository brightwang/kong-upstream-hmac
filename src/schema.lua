local typedefs = require "kong.db.schema.typedefs"

return {
  name = "kong-upstream-hmac",
  fields = {
    { consumer = typedefs.no_consumer },
    { protocols = typedefs.protocols_http },
    { config = {
      type = "record",
      fields = {
        { token = { type = "string", required = true } },
        { secret = { type = "string", required = true } },
        { validate_request_body = { type = "boolean", default = false } }
      }, }, },
  },
}
