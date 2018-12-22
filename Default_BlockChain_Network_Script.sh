#!/bin/bash
# This Script used to created default Blockchain environment with one Organizations.
# Replace the following configurations.
# Replace Network name that you have already Configured Swarm Network with overlay.
# Example: docker network create --attachable --driver overlay my_network
NETWORK=<Replace_Network_Name>

# Replace CA Port. Make sure you doesn't use this port previously.
CA_PORT1=<Replace_CA_Port>

# Replace Orderer Port. Make sure you doesn't use this port previously.
ORDERER_PORT=<Replace_Orderer_Port>

# Replace CouchDB Port. Make sure you doesn't use this port previously.
COUCH_DB_PORT=<Replace_CouchDB_Port>

# Replace Peer Port. Make sure you doesn't use this port previously.
# PEER_PORT1 is used to connecting the peers(Port_NO:7051)
# PEER_PORT2 is used to event hub services(Port_NO:7053)
PEER_PORT1=<Replace_Peer_Port>
PEER_PORT2=<Replace_Peer_Port2>

# Channel Name should be lowercase letters. Don't use numbers or special characters.
CHANNEL_NAME=<Replace_Channel_Name>

# Organization Name should be lowercase letters. Don't use numbers or special characters.
ORGANIZATION_NAME=<Replace_Organization_Name>

# Replace Host IP Address.
HOST=<Replace_Host_IP_Address>

echo -e "\e[1;35mMake sure you are replace the configurations in script file? Otherwise Press ctrl+c to stop.\e[0m";
echo -e "\e[1;35mSleep for 10 Seconds\e[0m";
sleep 10s
echo -e "\e[1;35mStart Network Creation\e[0m";

sudo chmod -R 777 *
cp crypto-config.yaml_original crypto-config.yaml
cp configtx.yaml_original configtx.yaml
echo -e "\e[1;35mReplace Configurations in yaml Files.\e[0m";
sed -i "s/<Replace_org_name>/$ORGANIZATION_NAME/g" configtx.yaml
sed -i "s/<Replace_org_name>/$ORGANIZATION_NAME/g" crypto-config.yaml
sed -i "s/<Replace_channel_name>/$CHANNEL_NAME/g" configtx.yaml
sed -i "s/<Replace_orderer_port>/$ORDERER_PORT/g" configtx.yaml

echo -e "\e[1;35mGenerating Certificates\e[0m";

./cryptogen generate --config=crypto-config.yaml
./configtxgen -profile ${CHANNEL_NAME} -outputCreateChannelTx ./composer-channel.tx -channelID ${CHANNEL_NAME}
./configtxgen -profile ComposerOrdererGenesis -outputBlock ./composer-genesis.block

echo -e "\e[1;35mCreating CA Container.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${CA_PORT1}:7054 -e ORGANIZATION_NAME=${ORGANIZATION_NAME} -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${NETWORK} -e FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server -e FABRIC_CA_SERVER_CA_NAME=ca.${ORGANIZATION_NAME}.example.com -v $PWD/crypto-config/peerOrganizations/${ORGANIZATION_NAME}.example.com/ca/:/etc/hyperledger/fabric-ca-server-config --name=ca.${ORGANIZATION_NAME}.example.swarm.com hyperledger/fabric-ca:1.2.1 sh -c 'fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.${ORGANIZATION_NAME}.example.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/*_sk -b admin:adminpw -d'

echo -e "\e[1;35mCreating Orderer Container.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${ORDERER_PORT}:7050 -e ORDERER_GENERAL_LOGLEVEL=debug -e ORDERER_GENERAL_LISTENADDRESS=0.0.0.0 -e ORDERER_GENERAL_GENESISMETHOD=file -e ORDERER_GENERAL_GENESISFILE=/etc/hyperledger/configtx/composer-genesis.block -e ORDERER_GENERAL_LOCALMSPID=OrdererMSP -e ORDERER_GENERAL_LOCALMSPDIR=/etc/hyperledger/msp/orderer/msp -v $PWD/:/etc/hyperledger/configtx -v $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/etc/hyperledger/msp/orderer/msp --workdir=/opt/gopath/src/github.com/hyperledger/fabric --name=orderer.example.swarm.com.${ORDERER_PORT} hyperledger/fabric-orderer:1.2.1 sh -c 'orderer'

echo -e "\e[1;35mCreating Couchdb Container.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${COUCH_DB_PORT}:5984 -e 'DB_URL: http://${HOST}:${COUCH_DB_PORT}/member_db' --name=couchdb-swarm-${COUCH_DB_PORT} hyperledger/fabric-couchdb:0.4.10

echo -e "\e[1;35mCreating Peer Container\e[0m";

docker run -it -d --network="${NETWORK}" -p ${PEER_PORT1}:7051  -p ${PEER_PORT2}:7053 -e CORE_LOGGING_LEVEL=debug -e CORE_CHAINCODE_LOGGING_LEVEL=DEBUG -e CORE_CHAINCODE_STARTUPTIMEOUT=900s -e CORE_CHAINCODE_EXECUTETIMEOUT=900s -e CORE_CHAINCODE_DEPLOYTIMEOUT=900s -e CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock -e CORE_PEER_ID=peer0.${ORGANIZATION_NAME}.example-swarm.com -e CORE_PEER_ADDRESS=peer0.${ORGANIZATION_NAME}.example-swarm.com:7051 -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${NETWORK} -e CORE_PEER_LOCALMSPID=${ORGANIZATION_NAME}MSP -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/msp -e CORE_LEDGER_STATE_STATEDATABASE=CouchDB -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=${HOST}:${COUCH_DB_PORT} -v /var/run/:/host/var/run/ -v $PWD:/etc/hyperledger/configtx -v $PWD/crypto-config/peerOrganizations/${ORGANIZATION_NAME}.example.com/peers/peer0.${ORGANIZATION_NAME}.example.com/msp:/etc/hyperledger/peer/msp -v $PWD/crypto-config/peerOrganizations/${ORGANIZATION_NAME}.example.com/users:/etc/hyperledger/msp/users --workdir=/opt/gopath/src/github.com/hyperledger/fabric --name=peer0.${ORGANIZATION_NAME}.example-swarm.com hyperledger/fabric-peer:1.2.1 sh -c 'peer node start'

echo -e "\e[1;35mAll containers created successfully\e[0m";

echo -e "\e[1;35mWait for 5 Seconds to Create and join Peers\e[0m";
sleep 5s

echo -e "\e[1;35mCreating a Channel\e[0m";

docker exec peer0.${ORGANIZATION_NAME}.example-swarm.com peer channel create -o ${HOST}:${ORDERER_PORT} -c ${CHANNEL_NAME} -f /etc/hyperledger/configtx/composer-channel.tx

echo -e "\e[1;35mPeer join to the Channel\e[0m";

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${ORGANIZATION_NAME}.example.com/msp" peer0.${ORGANIZATION_NAME}.example-swarm.com peer channel join -b ${CHANNEL_NAME}.block

echo -e "\e[1;35mYour Organization Name=${ORGANIZATION_NAME}\e[0m";
echo -e "\e[1;35mYour Channel Name =${CHANNEL_NAME}\e[0m";
echo -e "\e[1;35mBlockChain Network Created Successfully.\e[0m";
