# API Tech Forum 2016 materials

This repo contains the materials used in the demonstrations for API Tech Forum 2016,
at SmogShoppe in Los Angeles, 2016 December 7.


## Running the demos

You will need to deploy the [proxy bundle](apiproxy) into an Apigee Edge organization.
This proxy bundle relies on Java callouts, so it needs to be an evaluation or commercial organization. Trial organizations in Edge will not properly run Java callouts.

To deploy the proxy bundle from the filesystem, you can rely on [pushapi](https://github.com/carloseberhardt/apiploy) or another similar tool.  



## On JWT

One of the demonstrations exchanges a JWT for an opaque OAuth token. To exercise that part of the demonstration, you will need a public/private keypair. 


## To create a key pair:


```
mkdir keys
cd keys
openssl genrsa -out private.pem 2048
openssl pkcs8 -topk8 -inform pem -in private.pem -outform pem -nocrypt -out private-pkcs8.pem
openssl rsa -in private.pem -outform PEM -pubout -out public.pem
cd ..
```

## To provision a Developer + App for this Proxy

This will attach the public key to the developer app inside Edge.


```
tools/provisionDeveloperAndApp.sh -o ORGNAME -n -p APIPRODUCTNAME -k PUBLIC_KEY_FILE
```

eg,


```
tools/provisionDeveloperAndApp.sh -o cap500 -n -p ApiTechForum -k keys/public.pem 
```


Take note of the consumer (aka client) key and secret.  You can use this
in the requests-for-token, using grant types of client-credentials and
password.


## To create a JWT signed with that private key:

This simulates what the developer app would need to do, each time it requests a new token. 

```
tools/createJwt.sh -k PRIVATE_KEY_FILE  -i CONSUMER_KEY_HERE
```
eg

```
tools/createJwt.sh -k keys/private-pkcs8.pem  -i jB2prf9LeDsiJCrpnaR1naDUJZw5KAko
```

## To exchange the generated JWT for an opaque token

```
curl -X POST -H content-type:application/x-www-form-urlencoded \\
  https://cap500-test.apigee.net/jwt2token/token \\
 -d  'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=JWT.GOES.HERE'
```

## Postman Collection

There is [a postman collection](assets/0 - API Tech Forum.postman_collection)
with a number of requests contained therein.
You will need to set up a postman environment with an org and env setting.


## License

This material is copyright 2016 Google, Inc.
and is licensed under the [Apache 2.0 License](LICENSE). 

