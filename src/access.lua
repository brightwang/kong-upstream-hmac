local _M = {}
local hmac_sha1 = ngx.hmac_sha1
local encode_base64 = ngx.encode_base64
local openssl_hmac = require "openssl.hmac"
local kong = kong
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
    local body, err = kong.request.get_raw_body()
    if err then
        kong.log.debug(err)
        return false
    end
    local date = ngx.http_time(ngx.now())
    local digest = ""
    if validate_request_body then
        digest = general_digest(body)
    end
    local src_str = "date: " .. date
    local header_str = "date"
    local algorithm = "hmac-sha1"
    if validate_request_body then
        src_str = "digest: " .. digest .. "\n" .. src_str
        header_str = "digest " .. header_str
        ngx.req.set_header("Digest", digest)
    end
    local sign_str = hmac[algorithm](secret, src_str)
    sign_str = encode_base64(sign_str)
    ngx.req.set_header("Date", date)
    ngx.req.set_header("Authorization",
            fmt("hmac username=\"%s\", algorithm=\"hmac-sha1\", headers=\"%s\", signature=\"%s\"",
                    token, header_str, sign_str))
end

function _M.execute(conf)
    add_hmac_header(conf)
end

return _M
