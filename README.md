# kong-upstream-hmac

This plugin will add HMAC Signature authentication into the HTTP Header `Authorization` of proxied requests through the Kong gateway. The purpose of this, is to provide means of _Authentication_, _Authorization_ and _Non-Repudiation_ to API providers (APIs for which Kong is a gateway).

## Supported Kong Releases
Kong >= 0.12.x 

```
luarocks make *.rockspec

```
edit kong.conf
> plugins = bundled,kong-upstream-hmac

