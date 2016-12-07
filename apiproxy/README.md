# API Tech Forum

This API Proxy bundle includes all of the function for demonstrations at API Tech Forum, at SmogShoppe in Los Angeles, 2016 December 7.

This API Proxy bundle includes multiple inbound proxy endpoints:

* jwt2token
* oauth2-pwd-cc
* token-check
* json-protection
* sql-injection
* rate-limiting


## The jwt2token Endpoint

This endpoint performs a token exchange. 

It accepts as input a POST /token

with a x-www-form-urlencoded payload that includes
  grant_type = urn:ietf:params:oauth:grant-type:jwt-bearer
  assertion = a JWT

The JWT must:
* be signed via RS256,
* using the public key belonging to the developer.
* have an expiry of no greater than 300s.
* have never been previously used to obtain a token.
* have the correct audience and scope and issuer (==consumer key).

If all these checks  pass, then the proxy generates a Client_Credentials oauth token and returns it.

### Why

The reason to do token exchange is to allow fast server-side checking of tokens.
JWT are expensive to parse and verify, because they use public/private key signatures.

Exchanging a JWT for an opaque token allows a faster token check on the server side.

This is the pattern used by APIs for public Google services, including things like StackDriver, Drive, and so on.

