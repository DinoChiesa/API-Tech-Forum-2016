#!/bin/bash
# -*- mode:shell-script; coding:utf-8; -*-
#
# provisionDeveloperAndApp.sh
#
# A bash script for provisioning a developer and a developer app on
# an organization in the Apigee Edge Gateway, for a given API Product.
#
# Last saved: <2016-December-05 22:53:39>
#

verbosity=2
apiproductname="ApiTechForum"
pubkeyfile=""
developerEmail="dchiesa+1@google.com"
nametag="apitechforum"
defaultmgmtserver="https://api.enterprise.apigee.com"
netrccreds=0
credentials=""
TAB=$'\t'

function usage() {
  local CMD=`basename $0`
  echo "$CMD: "
  echo "  Creates a Developer and a Developer app for a given API Product." 
  echo "  Emits the client id and secret."
  echo "  Uses the curl utility."
  echo "usage: "
  echo "  $CMD [options] "
  echo "options: "
  echo "  -m url    the base url for the mgmt server."
  echo "  -o org    the org to use."
  echo "  -u creds  http basic authn credentials for the API calls."
  echo "  -n        tells curl to use .netrc to retrieve credentials"
  echo "  -d email  developer email.  Default: ${developerEmail}"
  echo "  -p prod   api product name.  Default: ${apiproductname}"
  echo "  -k file   file containing public key."
  echo "  -q        quiet; decrease verbosity by 1"
  echo "  -v        verbose; increase verbosity by 1"
  echo
  echo "Current parameter values:"
  echo "  mgmt api url: $defaultmgmtserver"
  echo "     verbosity: $verbosity"
  echo
  exit 1
}

## function MYCURL
## Print the curl command, omitting sensitive parameters, then run it.
## There are side effects:
## 1. puts curl output into file named ${CURL_OUT}. If the CURL_OUT
##    env var is not set prior to calling this function, it is created
##    and the name of a tmp file in /tmp is placed there.
## 2. puts curl http_status into variable CURL_RC
function MYCURL() {
  [[ -z "${CURL_OUT}" ]] && CURL_OUT=`mktemp /tmp/apigee-edge-provision-demo.curl.out.XXXXXX`
  [[ -f "${CURL_OUT}" ]] && rm ${CURL_OUT}
  [[ $verbosity -gt 0 ]] && echo "curl $@"

  # run the curl command
  CURL_RC=`curl $credentials -s -w "%{http_code}" -o "${CURL_OUT}" "$@"`
  [[ $verbosity -gt 0 ]] && echo "==> ${CURL_RC}"
}

function CleanUp() {
  [[ -f ${CURL_OUT} ]] && rm -rf ${CURL_OUT}
}

function echoerror() { echo "$@" 1>&2; }

function choose_mgmtserver() {
  local name
  echo
  read -p "  Which mgmt server (${defaultmgmtserver}) :: " name
  name="${name:-$defaultmgmtserver}"
  mgmtserver=$name
  echo "  mgmt server = ${mgmtserver}"
}


function choose_credentials() {
  local username password

  read -p "username for Edge org ${orgname} at ${mgmtserver} ? (blank to use .netrc): " username
  echo
  if [[ "$username" = "" ]] ; then  
    credentials="-n"
  else
    echo -n "Org Admin Password: "
    read -s password
    echo
    credentials="-u ${username}:${password}"
  fi
}

function maybe_ask_password() {
  local password
  if [[ ${credentials} =~ ":" ]]; then
    credentials="-u ${credentials}"
  else
    echo -n "password for ${credentials}?: "
    read -s password
    echo
    credentials="-u ${credentials}:${password}"
  fi
}



function check_org() {
  [[ $verbosity -gt 0 ]] && echo "checking org ${orgname}..."
  MYCURL -X GET  ${mgmtserver}/v1/o/${orgname}
  if [[ ${CURL_RC} -eq 200 ]]; then
    check_org=0
  else
    check_org=1
  fi
}


function random_string() {
  local rand_string
  rand_string=$(cat /dev/urandom |  LC_CTYPE=C  tr -cd '[:alnum:]' | head -c 10)
  echo ${rand_string}
}


function verify_api_product() {
    [[ $verbosity -gt 0 ]] && echo "check for the api product (${apiproductname})"
    MYCURL -X GET ${mgmtserver}/v1/o/${orgname}/apiproducts/${apiproductname} 
    if [[ ${CURL_RC} -ne 200 ]]; then
        echo
        echo CURL_RC = ${CURL_RC}
        echoerror "  failed checking that product."
        cat ${CURL_OUT}
        echo
        echo
        CleanUp
        exit 1
    fi

    cat ${CURL_OUT}
    echo
    echo
}


function create_new_developer_maybe() {
    local shortdevname
    [[ $verbosity -gt 0 ]] && echo "checking the developer (${developerEmail})..."
    MYCURL -X GET ${mgmtserver}/v1/o/${orgname}/developers/${developerEmail}
    if [[ ${CURL_RC} -eq 200 ]]; then
        echo
        echo "OK. the developer exists."
    else
        shortdevname=${nametag}-`random_string`
        [[ $verbosity -gt 0 ]] && echo "create a new developer (${developerEmail})..."
        MYCURL -X POST \
               -H "Content-type:application/json" \
               ${mgmtserver}/v1/o/${orgname}/developers \
               -d '{
    "email" : "'${developerEmail}'",
    "firstName" : "Dino",
    "lastName" : "Valentino",
    "userName" : "'${shortdevname}'",
    "organizationName" : "'${orgname}'",
    "status" : "active"
  }' 
        if [[ ${CURL_RC} -ne 201 ]]; then
            echo
            echo CURL_RC = ${CURL_RC}
            echoerror "  failed creating a new developer."
            cat ${CURL_OUT}
            echo
            echo
            CleanUp
            exit 1
        fi
    fi
}


function verify_public_key() {
    local grepout 
    if [[ ! -f ${pubkeyfile} ]]; then
        echo "the file containing the public key cannot be verified."
        echo 
        CleanUp
        exit 1
    fi
    # single square bracket to avoid pattern matching
    if [ ${pubkeyfile:(-4)} != ".pem" ]; then
        echo "you must use a pem-encoded cert file"
        CleanUp
        exit 1
    fi 
    grepout=$(grep -e "-----BEGIN PUBLIC KEY-----" ${pubkeyfile})
    if [[ $? -ne 0 ]]; then
        echo "cannot find the magic words in that file."
        CleanUp
        exit 1
    fi
    grepout=$(grep -e "-----END PUBLIC KEY-----" ${pubkeyfile})
    if [[ $? -ne 0 ]]; then
        echo "cannot find the magic words in that file."
        CleanUp
        exit 1
    fi

    pubkey=$(<"$pubkeyfile")
    pubkey=`echo $pubkey | tr '\r\n' ' '`
}



function create_new_app() {
    local payload
    appname=${nametag}-`random_string`
    [[ $verbosity -gt 0 ]] && echo "create a new app (${appname}) for that developer, with authorization for the product..."

    payload=$'{\n'
    payload+=$'  "attributes" : [ {\n'
    payload+=$'     "name" : "creator",\n'
    payload+=$'     "value" : "provisioning script '
    payload+="$0"
    payload+=$'"\n'
    payload+=$'    },{\n'
    payload+=$'     "name" : "public_key",\n'
    payload+=$'     "value" : "'
    payload+="$pubkey"
    payload+=$'"\n'
    payload+=$'    } ],\n'
    payload+=$'  "apiProducts": [ "'
    payload+="${apiproductname}"
    payload+=$'" ],\n'
    payload+=$'    "callbackUrl" : "thisisnotused://www.apigee.com",\n'
    payload+=$'    "name" : "'
    payload+="${appname}"
    payload+=$'",\n'
    payload+=$'    "keyExpiresIn" : "100000000"\n'
    payload+=$'}' 

    MYCURL -X POST \
           -H "Content-type:application/json" \
           ${mgmtserver}/v1/o/${orgname}/developers/${developerEmail}/apps \
           -d "${payload}"

    if [[ ${CURL_RC} -ne 201 ]]; then
        echo
        echo CURL_RC = ${CURL_RC}
        echoerror "  failed creating a new app."
        cat ${CURL_OUT}
        echo
        echo
        CleanUp
        exit 1
    fi
}


function retrieve_app_keys() {
  local array
  [[ $verbosity -gt 0 ]] && echo "get the keys for that app..."
  MYCURL -X GET ${mgmtserver}/v1/o/${orgname}/developers/${developerEmail}/apps/${appname} 

  if [[ ${CURL_RC} -ne 200 ]]; then
      echo
      echo CURL_RC = ${CURL_RC}
    echoerror "  failed retrieving the app details."
    cat ${CURL_OUT}
    echo
    echo
    CleanUp
    exit 1
  fi  

  array=(`cat ${CURL_OUT} | grep "consumerKey" | sed -E 's/[",:]//g'`)
  consumerkey=${array[1]}
  array=(`cat ${CURL_OUT} | grep "consumerSecret" | sed -E 's/[",:]//g'`)
  consumersecret=${array[1]}

  echo "consumer key: ${consumerkey}"
  echo "consumer secret: ${consumersecret}"
  echo 
  sleep 2
}






## =======================================================

while getopts "hm:o:u:nd:p:k:qv" opt; do
  case $opt in
    h) usage ;;
    m) mgmtserver=$OPTARG ;;
    o) orgname=$OPTARG ;;
    u) credentials="-u $OPTARG" ;;
    n) netrccreds=1 ;;
    p) apiproductname=$OPTARG ;;
    d) developerEmail=$OPTARG ;;
    k) pubkeyfile=$OPTARG ;;
    q) verbosity=$(($verbosity-1)) ;;
    v) verbosity=$(($verbosity+1)) ;;
    *) echo "unknown arg" && usage ;;
  esac
done

echo
if [[ "X$mgmtserver" = "X" ]]; then
  mgmtserver="$defaultmgmtserver"
fi 

if [[ "X$orgname" = "X" ]]; then
    echo "You must specify an org name (-o)."
    echo
    usage
    exit 1
fi

if [[ "X$credentials" = "X" ]]; then
  if [[ ${netrccreds} -eq 1 ]]; then
    credentials='-n'
  else
    choose_credentials
  fi 
else
  maybe_ask_password
fi 

if [[ "X$developerEmail" = "X" ]]; then
    echo "You must specify a developer email (-d)."
    echo
    usage
    exit 1
fi

if [[ "X$pubkeyfile" = "X" ]]; then
    echo "You must specify a filename for the public key (-k)."
    echo
    usage
    exit 1
fi

check_org 
if [[ ${check_org} -ne 0 ]]; then
  echo "that org cannot be validated"
  CleanUp
  exit 1
fi


verify_api_product
create_new_developer_maybe
verify_public_key
create_new_app
retrieve_app_keys

CleanUp
exit 0

