#!/bin/bash

source scriptUtils.sh

function createProducer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/Producer.pscm.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/Producer.pscm.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-Producer --tls.certfiles ${PWD}/organizations/fabric-ca/Producer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-Producer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-Producer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-Producer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-Producer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/Producer.pscm.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-Producer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/Producer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-Producer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/Producer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-Producer --id.name Produceradmin --id.secret Produceradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/Producer/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/Producer.pscm.com/peers
  mkdir -p organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-Producer -M ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/msp --csr.hosts peer0.Producer.pscm.com --tls.certfiles ${PWD}/organizations/fabric-ca/Producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Producer.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-Producer -M ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/tls --enrollment.profile tls --csr.hosts peer0.Producer.pscm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/Producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/Producer.pscm.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Producer.pscm.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/Producer.pscm.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Producer.pscm.com/tlsca/tlsca.Producer.pscm.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/Producer.pscm.com/ca
  cp ${PWD}/organizations/peerOrganizations/Producer.pscm.com/peers/peer0.Producer.pscm.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/Producer.pscm.com/ca/ca.Producer.pscm.com-cert.pem

  mkdir -p organizations/peerOrganizations/Producer.pscm.com/users
  mkdir -p organizations/peerOrganizations/Producer.pscm.com/users/User1@Producer.pscm.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-Producer -M ${PWD}/organizations/peerOrganizations/Producer.pscm.com/users/User1@Producer.pscm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/Producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Producer.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Producer.pscm.com/users/User1@Producer.pscm.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/Producer.pscm.com/users/Admin@Producer.pscm.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://Produceradmin:Produceradminpw@localhost:7054 --caname ca-Producer -M ${PWD}/organizations/peerOrganizations/Producer.pscm.com/users/Admin@Producer.pscm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/Producer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Producer.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Producer.pscm.com/users/Admin@Producer.pscm.com/msp/config.yaml

}

function createProcessor() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/Processor.pscm.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/Processor.pscm.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-Processor --tls.certfiles ${PWD}/organizations/fabric-ca/Processor/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-Processor.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-Processor.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-Processor.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-Processor.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/Processor.pscm.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-Processor --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/Processor/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-Processor --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/Processor/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-Processor --id.name Processoradmin --id.secret Processoradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/Processor/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/Processor.pscm.com/peers
  mkdir -p organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-Processor -M ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/msp --csr.hosts peer0.Processor.pscm.com --tls.certfiles ${PWD}/organizations/fabric-ca/Processor/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Processor.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:9054 --caname ca-Processor -M ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/tls --enrollment.profile tls --csr.hosts peer0.Processor.pscm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/Processor/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/Processor.pscm.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Processor.pscm.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/Processor.pscm.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Processor.pscm.com/tlsca/tlsca.Processor.pscm.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/Processor.pscm.com/ca
  cp ${PWD}/organizations/peerOrganizations/Processor.pscm.com/peers/peer0.Processor.pscm.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/Processor.pscm.com/ca/ca.Processor.pscm.com-cert.pem

  mkdir -p organizations/peerOrganizations/Processor.pscm.com/users
  mkdir -p organizations/peerOrganizations/Processor.pscm.com/users/User1@Processor.pscm.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:9054 --caname ca-Processor -M ${PWD}/organizations/peerOrganizations/Processor.pscm.com/users/User1@Processor.pscm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/Processor/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Processor.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Processor.pscm.com/users/User1@Processor.pscm.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/Processor.pscm.com/users/Admin@Processor.pscm.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://Processoradmin:Processoradminpw@localhost:9054 --caname ca-Processor -M ${PWD}/organizations/peerOrganizations/Processor.pscm.com/users/Admin@Processor.pscm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/Processor/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Processor.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Processor.pscm.com/users/Admin@Processor.pscm.com/msp/config.yaml

}

function createDistributor() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/Distributor.pscm.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/Distributor.pscm.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:6054 --caname ca-Distributor --tls.certfiles ${PWD}/organizations/fabric-ca/Distributor/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-Distributor.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-Distributor.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-Distributor.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-6054-ca-Distributor.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/Distributor.pscm.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-Distributor --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/Distributor/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-Distributor --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/Distributor/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-Distributor --id.name Distributoradmin --id.secret Distributoradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/Distributor/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/Distributor.pscm.com/peers
  mkdir -p organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-Distributor -M ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/msp --csr.hosts peer0.Distributor.pscm.com --tls.certfiles ${PWD}/organizations/fabric-ca/Distributor/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:6054 --caname ca-Distributor -M ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/tls --enrollment.profile tls --csr.hosts peer0.Distributor.pscm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/Distributor/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributoradmin.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/tlsca/tlsca.Distributor.pscm.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/ca
  cp ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/peers/peer0.Distributor.pscm.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/ca/ca.Distributor.pscm.com-cert.pem

  mkdir -p organizations/peerOrganizations/Distributor.pscm.com/users
  mkdir -p organizations/peerOrganizations/Distributor.pscm.com/users/User1@Distributor.pscm.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:6054 --caname ca-Distributor -M ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/users/User1@Distributor.pscm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/Distributor/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/users/User1@Distributor.pscm.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/Distributor.pscm.com/users/Admin@Distributor.pscm.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://Distributoradmin:Distributoradminpw@localhost:6054 --caname ca-Distributor -M ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/users/Admin@Distributor.pscm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/Distributor/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Distributor.pscm.com/users/Admin@Distributor.pscm.com/msp/config.yaml

}

function createRetailer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/peerOrganizations/Retailer.pscm.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/Retailer.pscm.com/
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-Retailer --tls.certfiles ${PWD}/organizations/fabric-ca/Retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-Retailer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-Retailer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-Retailer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-Retailer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/peerOrganizations/Retailer.pscm.com/msp/config.yaml

  infoln "Register peer0"
  set -x
  fabric-ca-client register --caname ca-Retailer --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/organizations/fabric-ca/Retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register user"
  set -x
  fabric-ca-client register --caname ca-Retailer --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/organizations/fabric-ca/Retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the org admin"
  set -x
  fabric-ca-client register --caname ca-Retailer --id.name Retaileradmin --id.secret Retaileradminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/Retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/peerOrganizations/Retailer.pscm.com/peers
  mkdir -p organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com

  infoln "Generate the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-Retailer -M ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/msp --csr.hosts peer0.Retailer.pscm.com --tls.certfiles ${PWD}/organizations/fabric-ca/Retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/msp/config.yaml

  infoln "Generate the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-Retailer -M ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/tls --enrollment.profile tls --csr.hosts peer0.Retailer.pscm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/Retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/tls/ca.crt
  cp ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/tls/signcerts/* ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/tls/server.crt
  cp ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/tls/keystore/* ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/tls/server.key

  mkdir -p ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/msp/tlscacerts
  cp ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/msp/tlscacerts/ca.crt

  mkdir -p ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/tlsca
  cp ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/tls/tlscacerts/* ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/tlsca/tlsca.Retailer.pscm.com-cert.pem

  mkdir -p ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/ca
  cp ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/peers/peer0.Retailer.pscm.com/msp/cacerts/* ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/ca/ca.Retailer.pscm.com-cert.pem

  mkdir -p organizations/peerOrganizations/Retailer.pscm.com/users
  mkdir -p organizations/peerOrganizations/Retailer.pscm.com/users/User1@Retailer.pscm.com

  infoln "Generate the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-Retailer -M ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/users/User1@Retailer.pscm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/Retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/users/User1@Retailer.pscm.com/msp/config.yaml

  mkdir -p organizations/peerOrganizations/Retailer.pscm.com/users/Admin@Retailer.pscm.com

  infoln "Generate the org admin msp"
  set -x
  fabric-ca-client enroll -u https://Retaileradmin:Retaileradminpw@localhost:8054 --caname ca-Retailer -M ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/users/Admin@Retailer.pscm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/Retailer/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/msp/config.yaml ${PWD}/organizations/peerOrganizations/Retailer.pscm.com/users/Admin@Retailer.pscm.com/msp/config.yaml

}

function createOrderer() {

  infoln "Enroll the CA admin"
  mkdir -p organizations/ordererOrganizations/pscm.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/pscm.com
  #  rm -rf $FABRIC_CA_CLIENT_HOME/fabric-ca-client-config.yaml
  #  rm -rf $FABRIC_CA_CLIENT_HOME/msp

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' >${PWD}/organizations/ordererOrganizations/pscm.com/msp/config.yaml

  infoln "Register orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  infoln "Register the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  mkdir -p organizations/ordererOrganizations/pscm.com/orderers
  mkdir -p organizations/ordererOrganizations/pscm.com/orderers/pscm.com

  mkdir -p organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com

  infoln "Generate the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/msp --csr.hosts orderer.pscm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/pscm.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/msp/config.yaml

  infoln "Generate the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/tls --enrollment.profile tls --csr.hosts orderer.pscm.com --csr.hosts localhost --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/tls/ca.crt
  cp ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/tls/signcerts/* ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/tls/server.crt
  cp ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/tls/keystore/* ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/tls/server.key

  mkdir -p ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/msp/tlscacerts/tlsca.pscm.com-cert.pem

  mkdir -p ${PWD}/organizations/ordererOrganizations/pscm.com/msp/tlscacerts
  cp ${PWD}/organizations/ordererOrganizations/pscm.com/orderers/orderer.pscm.com/tls/tlscacerts/* ${PWD}/organizations/ordererOrganizations/pscm.com/msp/tlscacerts/tlsca.pscm.com-cert.pem

  mkdir -p organizations/ordererOrganizations/pscm.com/users
  mkdir -p organizations/ordererOrganizations/pscm.com/users/Admin@pscm.com

  infoln "Generate the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M ${PWD}/organizations/ordererOrganizations/pscm.com/users/Admin@pscm.com/msp --tls.certfiles ${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem
  { set +x; } 2>/dev/null

  cp ${PWD}/organizations/ordererOrganizations/pscm.com/msp/config.yaml ${PWD}/organizations/ordererOrganizations/pscm.com/users/Admin@pscm.com/msp/config.yaml

}
