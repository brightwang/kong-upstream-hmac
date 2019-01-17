local _M = {}
local hmac_sha1 = ngx.hmac_sha1
local parse_time = ngx.parse_http_time
local decode_base64 = ngx.decode_base64
local encode_base64 = ngx.encode_base64
local utils = require "kong.tools.utils"
local constants = require "kong.constants"
local openssl_hmac = require "openssl.hmac"
local kong = kong
local DIGEST = "digest"
local DATE = "date"
local fmt = string.format
local sha256 = require "resty.sha256"


local hmac = {
    ["hmac-sha1"] = function(secret, data)
        return hmac_sha1(secret, data)
    end,
    ["hmac-sha256"] = function(secret, data)
        return openssl_hmac.new(secret, "sha256"):final(data)
    end,
    ["hmac-sha384"] = function(secret, data)
        return openssl_hmac.new(secret, "sha384"):final(data)
    end,
    ["hmac-sha512"] = function(secret, data)
        return openssl_hmac.new(secret, "sha512"):final(data)
    end,
}
local function general_digest(body)
    local digest = sha256:new()
    digest:update(body or '')
    local digest_created = "SHA-256=" .. encode_base64(digest:final())
    return digest_created
end

local function add_hmac_header(conf)
    local token = conf.token
    local secret = conf.secret
    local validate_request_body = conf.validate_request_body
    local method = kong.request.get_method()
    local request_uri = ngx.var.upstream_uri
    local raw_query = kong.request.get_raw_query()
    if not (raw_query == nil or raw_query == '') then
        request_uri = request_uri .. "?" .. kong.request.get_raw_query()
    end
    local request_line = fmt("%s %s HTTP/%s", method,
        request_uri, kong.request.get_http_version())
    local body, err = kong.request.get_raw_body()
    if err then
        kong.log.debug(err)
        return false
    end
    local date = ngx.cookie_time(ngx.now())
    local digest = general_digest(body)
    local src_str = "date: " .. date .. "\n" .. request_line
    local header_str = "date request-line"
    local algorithm = "hmac-sha1"
    if validate_request_body then
        src_str = "digest: SHA-256=" .. digest .. "\n" .. src_str
        header_str = "digest " .. header_str
        ngx.req.set_header("Digest", digest)
    end
    local sign_str = hmac[algorithm](secret, src_str)
    sign_str = encode_base64(sign_str)
    ngx.req.set_header("Date", date)
    ngx.req.set_header("Authorization",
        fmt("hmac username=\"%s\", algorithm=\"hmac-sha1\", headers=\"%s\", signature=\"%s\"",
            token, header_str, sign_str))
    kong.log.err("request_uri: ", request_uri)
    kong.log.err("date: ", date)
    kong.log.err("Authorization: ", fmt("hmac usename=\"%s\", algorithm=\"hmac-sha1\", headers=\"%s\", signature=\"%s\"",
        token, header_str, sign_str))
end



function _M.execute(conf)
    add_hmac_header(conf)
end

return _M
