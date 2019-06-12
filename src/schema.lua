return {
    no_consumer = true,
    fields = {
        token = { type = "string", required = true },
        secret = { type = "string", required = true },
        validate_request_body = { type = "boolean", default = false }
    }
}
