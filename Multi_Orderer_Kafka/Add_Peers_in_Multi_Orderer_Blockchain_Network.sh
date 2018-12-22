#!/bin/bash
# This Script used to Adding New Peers in Multi Orderer Kafka Hyperledger Fabric Blockchain Network.
# Replace the following configurations.

# Replace Network name that you have already created environment.Don't use new Network name.
NETWORK=<Replace_Network_Name>

# Replace Orderer Port which you have created already.
ORDERER_PORT=<Replace_Orderer_Port>

# Replace Couchdb New Port for New Peer.
COUCH_DB_PORT=<Replace_CouchDB_Port>

# Replace Peer Count number.If you have already created 2 peers then You can specify the count as 3.
PEER_COUNT_NUMBER=<Replace_Peer_Count>

# Replace Peer Port. Make sure you doesn't use this port previously.
# PEER_PORT1 is used to connecting the peers(Port_NO:7051)
# PEER_PORT2 is used to event hub services(Port_NO:7053)
PEER_PORT1=<Replace_Peer_Port1>
PEER_PORT2=<Replace_Peer_Port2>

# Replace the channel name that you have already created. Don't Replace with New Channel name.
CHANNEL_NAME=<Replace_Channel_Name>

# Replace the organization name that you have already created. Don't Replace with New organization name.
ORGANIZATION_NAME=<Replace_Organization_Name>

# Replace Host IP Address.
HOST=<Replace_Host_IP_Address>

echo -e "\e[1;35mMake sure you have replaced the configurations in script file? Otherwise Press ctrl + c to stop.\e[0m";

echo -e "\e[1;35mSleep for 10 Seconds\e[0m";
sleep 10s
echo -e "\e[1;35mStart Network Creation\e[0m";
echo -e "\e[1;35mReplace Configurations in yaml Files.\e[0m";
PEER_IDENTITY_COUNT=$(expr $PEER_COUNT_NUMBER - 1)

sed -ri 's/(Count:).*/\1 '$PEER_COUNT_NUMBER'/' "crypto-config.yaml";

echo -e "\e[1;35mGenerating Certificates\e[0m";

./cryptogen extend --config=crypto-config.yaml

echo -e "\e[1;35mCreating Couchdb Container.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${COUCH_DB_PORT}:5984 -e 'DB_URL: http://${HOST}:${COUCH_DB_PORT}/member_db' --name=couchdb-swarm-${COUCH_DB_PORT} hyperledger/fabric-couchdb:0.4.10

echo -e "\e[1;35mCreating Peer Container\e[0m";

docker run -it -d --network="${NETWORK}" -p ${PEER_PORT1}:7051 -p ${PEER_PORT2}:7053  -e CORE_LOGGING_LEVEL=debug -e CORE_CHAINCODE_LOGGING_LEVEL=DEBUG -e CORE_CHAINCODE_STARTUPTIMEOUT=900s -e CORE_CHAINCODE_EXECUTETIMEOUT=900s -e CORE_CHAINCODE_DEPLOYTIMEOUT=900s -e CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock -e CORE_PEER_ID=peer${PEER_IDENTITY_COUNT}.${ORGANIZATION_NAME}.example-swarm.com -e CORE_PEER_ADDRESS=peer${PEER_IDENTITY_COUNT}.${ORGANIZATION_NAME}.example-swarm.com:7051 -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${NETWORK} -e CORE_PEER_LOCALMSPID=${ORGANIZATION_NAME}MSP -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/msp -e CORE_LEDGER_STATE_STATEDATABASE=CouchDB -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=${HOST}:${COUCH_DB_PORT} -v /var/run/:/host/var/run/ -v $PWD:/etc/hyperledger/configtx -v $PWD/crypto-config/peerOrganizations/${ORGANIZATION_NAME}.example.com/peers/peer${PEER_IDENTITY_COUNT}.${ORGANIZATION_NAME}.example.com/msp:/etc/hyperledger/peer/msp -v $PWD/crypto-config/peerOrganizations/${ORGANIZATION_NAME}.example.com/peers/peer${PEER_IDENTITY_COUNT}.${ORGANIZATION_NAME}.example.com/tls:/etc/hyperledger/peer/tls -v $PWD/crypto-config/peerOrganizations/${ORGANIZATION_NAME}.example.com/users:/etc/hyperledger/msp/users --workdir=/opt/gopath/src/github.com/hyperledger/fabric --name=peer${PEER_IDENTITY_COUNT}.${ORGANIZATION_NAME}.example-swarm.com hyperledger/fabric-peer:1.2.1 sh -c 'peer node start'

echo -e "\e[1;35mAll containers created successfully\e[0m";

echo -e "\e[1;35mWait for 5 Seconds to Create and join Peers\e[0m";
sleep 5s

echo -e "\e[1;35mFetching a Channel information\e[0m";

docker exec peer${PEER_IDENTITY_COUNT}.${ORGANIZATION_NAME}.example-swarm.com peer channel fetch 0 ${CHANNEL_NAME}.block -o ${HOST}:${ORDERER_PORT} -c ${CHANNEL_NAME}

echo -e "\e[1;35mPeer join to the Channel\e[0m";

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${ORGANIZATION_NAME}.example.com/msp" peer${PEER_IDENTITY_COUNT}.${ORGANIZATION_NAME}.example-swarm.com peer channel join -b ${CHANNEL_NAME}.block

echo -e "\e[1;35mYour Organization Name=${ORGANIZATION_NAME}\e[0m";
echo -e "\e[1;35mYour Channel Name =${CHANNEL_NAME}\e[0m";
echo -e "\e[1;35mNew Peer Joined Successfully.\e[0m";
