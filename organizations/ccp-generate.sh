#!/bin/bash

function one_line_pem {
    echo "`awk 'NF {sub(/\\n/, ""); printf "%s\\\\\\\n",$0;}' $1`"
}

function json_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.json
}

function yaml_ccp {
    local PP=$(one_line_pem $4)
    local CP=$(one_line_pem $5)
    sed -e "s/\${ORG}/$1/" \
        -e "s/\${P0PORT}/$2/" \
        -e "s/\${CAPORT}/$3/" \
        -e "s#\${PEERPEM}#$PP#" \
        -e "s#\${CAPEM}#$CP#" \
        organizations/ccp-template.yaml | sed -e $'s/\\\\n/\\\n          /g'
}

ORG=1
P0PORT=7051
CAPORT=7054
PEERPEM=organizations/peerOrganizations/Producer.pscm.com/tlsca/tlsca.Producer.pscm.com-cert.pem
CAPEM=organizations/peerOrganizations/Producer.pscm.com/ca/ca.Producer.pscm.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/Producer.pscm.com/connection-Producer.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/Producer.pscm.com/connection-Producer.yaml

ORG=2
P0PORT=9051
CAPORT=9054
PEERPEM=organizations/peerOrganizations/Processor.pscm.com/tlsca/tlsca.Processor.pscm.com-cert.pem
CAPEM=organizations/peerOrganizations/Processor.pscm.com/ca/ca.Processor.pscm.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/Processor.pscm.com/connection-Processor.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/Processor.pscm.com/connection-Processor.yaml

ORG=3
P0PORT=6051
CAPORT=6054
PEERPEM=organizations/peerOrganizations/Distributor.pscm.com/tlsca/tlsca.Distributor.pscm.com-cert.pem
CAPEM=organizations/peerOrganizations/Distributor.pscm.com/ca/ca.Distributor.pscm.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/Distributor.pscm.com/connection-Distributor.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/Distributor.pscm.com/connection-Distributor.yaml

ORG=4
P0PORT=8051
CAPORT=8054
PEERPEM=organizations/peerOrganizations/Retailer.pscm.com/tlsca/tlsca.Retailer.pscm.com-cert.pem
CAPEM=organizations/peerOrganizations/Retailer.pscm.com/ca/ca.Retailer.pscm.com-cert.pem

echo "$(json_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/Retailer.pscm.com/connection-Retailer.json
echo "$(yaml_ccp $ORG $P0PORT $CAPORT $PEERPEM $CAPEM)" > organizations/peerOrganizations/Retailer.pscm.com/connection-Retailer.yaml




