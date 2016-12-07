# API Tech Forum 2016 materials

This repo contains the materials used in the demonstrations for API Tech Forum 2016,
at SmogShoppe in Los Angeles, 2016 December 7.

## To create a key pair:

```
openssl genrsa -out private.pem 2048
openssl pkcs8 -topk8 -inform pem -in private.pem -outform pem -nocrypt -out private-pkcs8.pem
openssl rsa -in private.pem -outform PEM -pubout -out public.pem
```


## To create a JWT signed with that private key:

```
tools/createJwt.sh -k PRIVATE_KEY_FILE  -i CONSUMER_KEY_HERE
```
eg

```
tools/createJwt.sh -k keys/private-pkcs8.pem  -i jB2prf9LeDsiJCrpnaR1naDUJZw5KAko
```

## To exchange the JWT for an opaque token

curl -X POST -H content-type:application/x-www-form-urlencoded \
  https://cap500-test.apigee.net/jwt2token/token \
 -d  'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJpc3MiOiJ1WTZKeE02MThweHBpaUxnNzRhRE5lam5qck9Bb2FPSCIsImF1ZCI6Imh0dHBzOlwvXC93d3cuY2FwNTAwLmNvbVwvYXBpdGVjaGZvcm1cL3Rva2VuIiwiZXhwIjoxNDgxMDAwOTA1LCJpYXQiOjE0ODEwMDA2MDUsInNjb3BlIjoiaHR0cHM6XC9cL3d3dy5leGFtcGxlLmNvbVwvYXBpdGVjaGZvcnVtLnJlYWRvbmx5In0.fFBID_HOohjE8eiPKGxX0T3k024ujHAmbgNpgzGRs30DlRNfa0BqkCdtCYwMbtFM0SuzlwIV7lzt-nqac_vKPRZKBdwW6l_WGc33t9B3ZGxklE6lcqBD25oubwd95_nvrnlpuf1Fo3K1nHKJr8n1RocHsn2DLT2W18r3xQVFFDzEN-JNMf8ok9i9fkRF4gXF6zNTQ9X-0F_HvzEzLwuhu_4IdFMdjHk02xK1fAQZcbzkSUH8QKaciG5z7u89vM2HWBrKYp6DFxelD9f1iGYfw9JW3VbyH8AeQXGGknUVez_V2HLj2sj4pSEqzUXd1JdUJ7Yx3ygdWrezpF6JoNY7GA'


## License

This material is copyright 2016 Google, Inc.
and is licensed under the [Apache 2.0 License](LICENSE). 

