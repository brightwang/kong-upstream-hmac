# kong-upstream-hmac

This plugin will add HMAC Signature authentication into the HTTP Header `Authorization` of proxied requests through the Kong gateway. The purpose of this, is to provide means of _Authentication_, _Authorization_ and _Non-Repudiation_ to API providers (APIs for which Kong is a gateway).

## Supported Kong Releases
Kong >= 0.12.x 

```
luarocks install kong-upstream-hmac
```

##### Edit kong.conf
> plugins = bundled,kong-upstream-hmac


##### Configure this plugin on a Route with:
      
```
curl -X POST http://kong:8001/routes/{route-id}/plugins -d "name=kong-upstream-hmac" -d "config.token=token" -d "config.secret=secret"

```