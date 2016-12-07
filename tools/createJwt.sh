#!/bin/bash
# -*- mode:shell-script; coding:utf-8; -*-
#
# Created: <Mon Dec  5 17:51:55 2016>
# Last Updated: <2016-December-05 21:11:49>
#

jdir=/Users/dino/dev/java
privateKey=""
issuer=""
expiry=300
scope="https://www.example.com/apitechforum.readonly"
audience="https://www.cap500.com/apitechform/token"

function usage() {
  local CMD=`basename $0`
  echo "$CMD: "
  echo "  Create a JWT for use with the jwt2token API proxy. "
  echo "  Uses the JwtNimbusTool Java program."
  echo "usage: "
  echo "  $CMD [options] "
  echo "options: "
  echo "  -k privkey   private key file."
  echo "  -i iss       issuer claim for the JWT."
  echo "  -e NNN       lifetime of the JWT in seconds. default: 300"
  echo "  -a audience  audience. Defaults to ${audience}"
  echo "  -s scope     scope. defaults to ${scope}"
  echo
  exit 1
}


while getopts "hk:i:e:a:s:" opt; do
  case $opt in
    h) usage ;;
    k) privateKey=$OPTARG ;;
    i) issuer=$OPTARG ;;
    e) expiry=$OPTARG ;;
    a) audience=$OPTARG ;;
    s) scope=$OPTARG ;;
    *) echo "unknown arg" && usage ;;
  esac
done

####################################################################

[[ ! -f "${privateKey}" ]] && echo "you must provide a private key" && echo && usage
[[ -z "${issuer}" ]] && echo "you must provide an issuer" && echo && usage

claims=$'{\n'
claims+=$'   "iss":"'
claims+=${issuer}
claims+=$'",\n'
claims+=$'   "scope":"'
claims+=${scope}
claims+=$'",\n'
claims+=$'   "aud":"'
claims+=${audience}
claims+=$'"\n}'

echo "claims: "
echo "${claims}"

jwt=$(java -classpath ${jdir}:${jdir}/lib/nimbus-jose-jwt-3.1.2.jar:${jdir}/lib/json-smart-1.3.jar:${jdir}/lib/not-yet-commons-ssl-0.3.9.jar:${jdir}/lib/commons-lang-2.6.jar:${jdir}/lib/commons-codec-1.7.jar  JwtToolNimbus -g -k ${privateKey} -c "${claims}" -x ${expiry})

echo
echo
echo "The JWT is: "
echo $jwt
echo
echo
echo "To use the JWT:"
echo
echo "curl -X POST -H content-type:application/x-www-form-urlencoded \\"
echo "    https://cap500-test.apigee.net/jwt2token/token \\"
printf "    -d  'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=%s'" $jwt
  



