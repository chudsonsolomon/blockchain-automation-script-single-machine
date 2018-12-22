#!/bin/bash
# This Script used to add New Organization with Existing Blockchain Network.
# Replace the following configurations.

# Replace the network name that you have already created your previous organizations.
NETWORK=<Replace_Network_Name>

# Replace CA Port. Make sure You doesn't use this port previously.
CA_PORT1=<Replace_CA_Port>

# Replace the Orderer Port that you have already created your previous organization. Don't use New Orderer Port.
ORDERER_PORT=<Replace_Orderer_Port>

# Replace CouchDB Port. Make sure You doesn't use this port previously.
COUCH_DB_PORT=<Replace_CouchDB_Port>

# Replace Peer Port. Make sure You doesn't use this port previously.
# PEER_PORT1 is used to connecting the peers(Port_NO:7051)
# PEER_PORT2 is used to event hub services(Port_NO:7053)
PEER_PORT1=<Replace_Peer_Port1>
PEER_PORT2=<Replace_Peer_Port2>

# Channel Name should be lowercase letters. Don't use numbers or special characters.
CHANNEL_NAME=<Replace_Channel_Name>

# Organization Name should be lowercase letters. Don't use numbers or special characters.
ORGANIZATION_NAME=<Replace_Organization_Name>
FIRST_ORGANIZATION_NAME=<Replace_First_Organization_Name>

# If you already have more than one organization Please specify Previous organization names except first organization.(comma(,) seperated value). Otherwise leave it blank.
# PREVIOUS_ORGANIZATIONS=<Replace Previous_Organization_Names>
PREVIOUS_ORGANIZATIONS=

# Replace Host IP Address.
HOST=<Replace_Host_IP_Address>

echo -e "\e[1;35mMake sure you are replace the configurations in script file? Otherwise Press ctrl+c to stop.\e[0m";
echo -e "\e[1;35mSleep for 10 Seconds\e[0m";
echo -e "\e[1;35mCreating New Organization - ${ORGANIZATION_NAME}\e[0m";
sleep 10s
echo -e "\e[1;35mStart Network Creation\e[0m";
cp configtx.yaml_original configtx.yaml
cp crypto-config.yaml_original crypto-config.yaml
echo -e "\e[1;35mReplace Configurations in yaml Files.\e[0m";
sed -i "s/<Replace_org_name>/$ORGANIZATION_NAME/g" configtx.yaml
sed -i "s/<Replace_org_name>/$ORGANIZATION_NAME/g" crypto-config.yaml

echo -e "\e[1;35mGenerating Certificates\e[0m";

./cryptogen generate --config=crypto-config.yaml
./configtxgen -printOrg ${ORGANIZATION_NAME} > $ORGANIZATION_NAME.json

echo -e "\e[1;35mCreating CA Container.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${CA_PORT1}:7054 -e ORGANIZATION_NAME=${ORGANIZATION_NAME} -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${NETWORK} -e FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server -e FABRIC_CA_SERVER_CA_NAME=ca.${ORGANIZATION_NAME}.example.com -v $PWD/crypto-config/peerOrganizations/${ORGANIZATION_NAME}.example.com/ca/:/etc/hyperledger/fabric-ca-server-config --name=ca.${ORGANIZATION_NAME}.example.swarm.com hyperledger/fabric-ca:1.2.1 sh -c 'fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.${ORGANIZATION_NAME}.example.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/*_sk -b admin:adminpw -d'

echo -e "\e[1;35mCreating Couchdb Container.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${COUCH_DB_PORT}:5984 -e 'DB_URL: http://${HOST}:${COUCH_DB_PORT}/member_db' --name=couchdb-swarm-${COUCH_DB_PORT} hyperledger/fabric-couchdb:0.4.10

echo -e "\e[1;35mCreating Peer Container\e[0m";

docker run -it -d --network="${NETWORK}" -p ${PEER_PORT1}:7051 -p ${PEER_PORT2}:7053 -e CORE_LOGGING_LEVEL=debug -e CORE_CHAINCODE_LOGGING_LEVEL=DEBUG -e CORE_CHAINCODE_STARTUPTIMEOUT=900s -e CORE_CHAINCODE_EXECUTETIMEOUT=900s -e CORE_CHAINCODE_DEPLOYTIMEOUT=900s -e CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock -e CORE_PEER_ID=peer0.${ORGANIZATION_NAME}.example-swarm.com -e CORE_PEER_ADDRESS=peer0.${ORGANIZATION_NAME}.example-swarm.com:7051 -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${NETWORK} -e CORE_PEER_LOCALMSPID=${ORGANIZATION_NAME}MSP -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/msp -e CORE_LEDGER_STATE_STATEDATABASE=CouchDB -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=${HOST}:${COUCH_DB_PORT} -v /var/run/:/host/var/run/ -v $PWD:/etc/hyperledger/configtx -v $PWD/crypto-config/peerOrganizations/${ORGANIZATION_NAME}.example.com/peers/peer0.${ORGANIZATION_NAME}.example.com/msp:/etc/hyperledger/peer/msp -v $PWD/crypto-config/peerOrganizations/${ORGANIZATION_NAME}.example.com/users:/etc/hyperledger/msp/users --workdir=/opt/gopath/src/github.com/hyperledger/fabric --name=peer0.${ORGANIZATION_NAME}.example-swarm.com hyperledger/fabric-peer:1.2.1 sh -c 'peer node start'

echo -e "\e[1;35mAll containers created successfully\e[0m";

echo -e "\e[1;35mWait for 5 Seconds to Create and join Peers\e[0m";
sleep 5s

docker cp configtxlator peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com:/usr/bin/
docker cp  ${ORGANIZATION_NAME}.json peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/


echo -e "\e[1;35mUpdate Channel Information in Previous Organizations\e[0m";

rm -rf config.json
rm -rf modified_config.json

docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com peer channel fetch config config_block.pb -o ${HOST}:${ORDERER_PORT} -c ${CHANNEL_NAME}
if [ -z "$PREVIOUS_ORGANIZATIONS" ]; then
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com apt-get update
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com apt-get install jq -y
fi
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json
docker cp config.json peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"'$ORGANIZATION_NAME'MSP":.[1]}}}}}' config.json $ORGANIZATION_NAME.json > modified_config.json
docker cp modified_config.json peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com configtxlator proto_encode --input config.json --type common.Config --output config.pb
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com configtxlator compute_update --channel_id ${CHANNEL_NAME} --original config.pb --updated modified_config.pb --output ${ORGANIZATION_NAME}_update.pb
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com configtxlator proto_decode --input ${ORGANIZATION_NAME}_update.pb --type common.ConfigUpdate | jq . > ${ORGANIZATION_NAME}_update.json
docker cp ${ORGANIZATION_NAME}_update.json peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat ${ORGANIZATION_NAME}_update.json)'}}}' | jq . > ${ORGANIZATION_NAME}_update_in_envelope.json
docker cp ${ORGANIZATION_NAME}_update_in_envelope.json peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com configtxlator proto_encode --input ${ORGANIZATION_NAME}_update_in_envelope.json --type common.Envelope --output ${ORGANIZATION_NAME}_update_in_envelope.pb


echo -e "\e[1;35mChannel Signature Process.\e[0m";
docker exec peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com peer channel signconfigtx -f ${ORGANIZATION_NAME}_update_in_envelope.pb
docker cp  peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/${ORGANIZATION_NAME}_update_in_envelope.pb ${ORGANIZATION_NAME}_update_in_envelope.pb

if [ ! -z "${PREVIOUS_ORGANIZATIONS}" ]; then
echo -e "\e[1;35mMoveSignature file to all previous organizations.\e[0m";
for prev_organizations in $(echo $PREVIOUS_ORGANIZATIONS | sed "s/,/ /g")
do
docker cp ${ORGANIZATION_NAME}_update_in_envelope.pb peer0.${prev_organizations}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/configtx/crypto-config/peerOrganizations/${prev_organizations}.example.com/users/Admin@${prev_organizations}.example.com/msp" -e "CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/configtx/crypto-config/peerOrganizations/${prev_organizations}.example.com/peers/peer0.${prev_organizations}.example.com/tls/ca.crt" peer0.${prev_organizations}.example-swarm.com peer channel signconfigtx -f ${ORGANIZATION_NAME}_update_in_envelope.pb
docker cp peer0.${prev_organizations}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/${ORGANIZATION_NAME}_update_in_envelope.pb ${ORGANIZATION_NAME}_update_in_envelope.pb 
echo ${prev_organizations}
done
fi
echo -e "\e[1;35mChannel Updation\e[0m";
docker cp ${ORGANIZATION_NAME}_update_in_envelope.pb peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/configtx/crypto-config/peerOrganizations/${FIRST_ORGANIZATION_NAME}.example.com/users/Admin@${FIRST_ORGANIZATION_NAME}.example.com/msp" -e "CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/configtx/crypto-config/peerOrganizations/${FIRST_ORGANIZATION_NAME}.example.com/peers/peer0.${FIRST_ORGANIZATION_NAME}.example.com/tls/ca.crt" peer0.${FIRST_ORGANIZATION_NAME}.example-swarm.com peer channel update -f ${ORGANIZATION_NAME}_update_in_envelope.pb -c ${CHANNEL_NAME} -o ${HOST}:${ORDERER_PORT}

echo -e "\e[1;35mFetching a Channel information\e[0m";

docker exec peer0.${ORGANIZATION_NAME}.example-swarm.com peer channel fetch 0 ${CHANNEL_NAME}.block -o ${HOST}:${ORDERER_PORT} -c ${CHANNEL_NAME}

echo -e "\e[1;35mPeer join to the Channel\e[0m";

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${ORGANIZATION_NAME}.example.com/msp" peer0.${ORGANIZATION_NAME}.example-swarm.com peer channel join -b ${CHANNEL_NAME}.block


echo -e "\e[1;35mYour Organization Name=${ORGANIZATION_NAME}\e[0m";
echo -e "\e[1;35mYour Channel Name =${CHANNEL_NAME}\e[0m";
echo -e "\e[1;35mNew Organization added Successfully with channel--${CHANNEL_NAME}.\e[0m";
