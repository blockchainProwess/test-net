#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

source scriptUtils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/msp/tlscacerts/tlsca.pscm.com-cert.pem
export PEER0_Producer_CA=${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/tls/ca.crt
export PEER0_Processor_CA=${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/tls/ca.crt
export PEER0_Distributor_CA=${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/tls/ca.crt
export PEER0_Retailer_CA=${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/tls/ca.crt

# Set OrdererOrg.Admin globals
setOrdererGlobals() {
  export CORE_PEER_LOCALMSPID="OrdererMSP"
  export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/msp/tlscacerts/tlsca.pscm.com-cert.pem
  export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/ordererOrganizations/pscm.com/users/Admin@pscm.com/msp
}

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [[$USING_ORG -eq "Producer"]]; then
    export CORE_PEER_LOCALMSPID="ProducerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Producer_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/Producer.pscm.com/users/Admin@Producer.pscm.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [[$USING_ORG -eq "Processor"]]; then
    export CORE_PEER_LOCALMSPID="ProcessorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Processor_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/Processor.pscm.com/users/Admin@Processor.pscm.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
  elif [[ $USING_ORG -eq "Distributor"]]; then
    export CORE_PEER_LOCALMSPID="DistributorMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Distributor_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/Distributor.pscm.com/users/Admin@Distributor.pscm.com/msp
    export CORE_PEER_ADDRESS=localhost:6051 
  elif [[ $USING_ORG -eq "Retailer"]]; then
    export CORE_PEER_LOCALMSPID="RetailerMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_Retailer_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/Retailer.pscm.com/users/Admin@Retailer.pscm.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {

  PEER_CONN_PARMS=""
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.$1"
    ## Set peer addresses
    PEERS="$PEERS $PEER"
    PEER_CONN_PARMS="$PEER_CONN_PARMS --peerAddresses $CORE_PEER_ADDRESS"
    ## Set path to TLS certificate
    TLSINFO=$(eval echo "--tlsRootCertFiles \$PEER0_$1_CA")
    PEER_CONN_PARMS="$PEER_CONN_PARMS $TLSINFO"
    # shift by one to get to the next organization
    shift
  done
  # remove leading space for output
  PEERS="$(echo -e "$PEERS" | sed -e 's/^[[:space:]]*//')"
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$4"
  fi
}

check() {
  infoln "READABLE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}
