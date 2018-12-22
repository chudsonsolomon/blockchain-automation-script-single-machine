#!/bin/bash
# This Script used to Create Multiple Organizations in Hyperledger Fabric Blockchain Network.
# Replace the following configurations.

# Replace the network name that you have already created with Docker Swarm.
NETWORK=<Replace_Network_Name>

# Replace First Org CA Port. Make sure You doesn't use this port previously. Specify only one port for first org CA Port.
FIRST_ORG_CA_PORT=<Replace_FIRST_ORG_CA_Port>

# Replace Other Org CA Port. Make sure You doesn't use this port previously.Comma(,) Seperated values for each Organizations.
OTHER_ORG_CA_PORT=<Replace_OTHER_ORG_CA_Port>

# Replace the Orderer Port.Make sure You doesn't use this port previously.
ORDERER_PORT=<Replace_Orderer_Port>

# Replace First Org CouchDB Port. Make sure You doesn't use this port previously.Specify only one port for first org Couch_DB Port.
FIRST_ORG_COUCH_DB_PORT=<Replace_FIRST_ORG_CouchDB_Port>

# Replace Other Org CouchDB Port. Make sure You doesn't use this port previously.Comma(,) Seperated values for each Organizations.
OTHER_ORG_COUCH_DB_PORT=<Replace_OTHER_ORG_CouchDB_Port>

# Replace First Org Peer Ports. Make sure You doesn't use this port previously.Specify only one port for first org Peer Port.
# PEER_PORT1 is used to connecting the peers(Port_NO:7051)
# PEER_PORT2 is used to event hub services(Port_NO:7053)
FIRST_ORG_PEER_PORT1=<Replace_FIRST_ORG_Peer_Port1>
FIRST_ORG_PEER_PORT2=<Replace_FIRST_ORG_Peer_Port2>

# Replace Other Org Peer Ports. Make sure You doesn't use this port previously. Comma(,) Seperated values for each Organizations.
# PEER_PORT1 is used to connecting the peers(Port_NO:7051)
# PEER_PORT2 is used to event hub services(Port_NO:7053)
OTHER_ORG_PEER_PORT1=<Replace_OTHER_ORG_Peer_Port1>
OTHER_ORG_PEER_PORT2=<Replace_OTHER_ORG_Peer_Port2>


# Channel Name should be lowercase letters. Don't use numbers or special characters.
CHANNEL_NAME=<Replace_Channel_Name>

# Default Organization Name should be lowercase letters. Don't use numbers or special characters. Don't Specify More than one Organization as default.
DEFAULT_ORGANIZATION_NAME=<Replace_First_Organization_Name>

# Other Organization Names should be lowercase letters. Don't use numbers or special characters.Comma(,) Seperated values for each Organizations.
OTHER_ORGANIZATION_NAMES=<Replace_Other_Organizations_Name>

# Replace Host IP Address.
HOST=<Replace_Host_IP_Address>

echo -e "\e[1;35mMake sure you are replace the configurations in script file? Otherwise Press ctrl+c to stop.\e[0m";
echo -e "\e[1;35mSleep for 10 Seconds\e[0m";
echo -e "\e[1;35mCreating your First Organization - ${DEFAULT_ORGANIZATION_NAME}\e[0m";
sleep 10s

echo -e "\e[1;35mReplace Configurations in yaml Files for First Organization - ${DEFAULT_ORGANIZATION_NAME}\e[0m";
cp configtx.yaml_firstorg_original configtx.yaml
cp crypto-config.yaml_firstorg_original crypto-config.yaml

sed -i "s/<Replace_org_name>/$DEFAULT_ORGANIZATION_NAME/g" configtx.yaml
sed -i "s/<Replace_org_name>/$DEFAULT_ORGANIZATION_NAME/g" crypto-config.yaml
sed -i "s/<Replace_channel_name>/$CHANNEL_NAME/g" configtx.yaml
sed -i "s/<Replace_orderer_port>/$ORDERER_PORT/g" configtx.yaml

echo -e "\e[1;35mGenerating Certificates for First Organization - ${DEFAULT_ORGANIZATION_NAME}\e[0m";

./cryptogen generate --config=crypto-config.yaml
./configtxgen -profile ${CHANNEL_NAME} -outputCreateChannelTx ./composer-channel.tx -channelID ${CHANNEL_NAME}
./configtxgen -profile ComposerOrdererGenesis -outputBlock ./composer-genesis.block


echo -e "\e[1;35mCreating CA Container for First Organizations - ${DEFAULT_ORGANIZATION_NAME}.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${FIRST_ORG_CA_PORT}:7054 -e DEFAULT_ORGANIZATION_NAME=${DEFAULT_ORGANIZATION_NAME} -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${NETWORK} -e FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server -e FABRIC_CA_SERVER_CA_NAME=ca.${DEFAULT_ORGANIZATION_NAME}.example.com -v $PWD/crypto-config/peerOrganizations/${DEFAULT_ORGANIZATION_NAME}.example.com/ca/:/etc/hyperledger/fabric-ca-server-config --name=ca.${DEFAULT_ORGANIZATION_NAME}.example.swarm.com hyperledger/fabric-ca:1.2.1 sh -c 'fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.${DEFAULT_ORGANIZATION_NAME}.example.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/*_sk -b admin:adminpw -d'

echo -e "\e[1;35mCreating Orderer Container for First Organizations - ${DEFAULT_ORGANIZATION_NAME}.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${ORDERER_PORT}:7050 -e ORDERER_GENERAL_LOGLEVEL=debug -e ORDERER_GENERAL_LISTENADDRESS=0.0.0.0 -e ORDERER_GENERAL_GENESISMETHOD=file -e ORDERER_GENERAL_GENESISFILE=/etc/hyperledger/configtx/composer-genesis.block -e ORDERER_GENERAL_LOCALMSPID=OrdererMSP -e ORDERER_GENERAL_LOCALMSPDIR=/etc/hyperledger/msp/orderer/msp -v $PWD/:/etc/hyperledger/configtx -v $PWD/crypto-config/ordererOrganizations/example.com/orderers/orderer.example.com/msp:/etc/hyperledger/msp/orderer/msp --workdir=/opt/gopath/src/github.com/hyperledger/fabric --name=orderer.example.swarm.com.${ORDERER_PORT} hyperledger/fabric-orderer:1.2.1 sh -c 'orderer'

echo -e "\e[1;35mCreating Couchdb Container for First Organizations - ${DEFAULT_ORGANIZATION_NAME}.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${FIRST_ORG_COUCH_DB_PORT}:5984 -e 'DB_URL: http://${HOST}:${FIRST_ORG_COUCH_DB_PORT}/member_db' --name=couchdb-swarm-${FIRST_ORG_COUCH_DB_PORT} hyperledger/fabric-couchdb:0.4.10

echo -e "\e[1;35mCreating Peer Container for First Organizations - ${DEFAULT_ORGANIZATION_NAME}.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${FIRST_ORG_PEER_PORT1}:7051  -p ${FIRST_ORG_PEER_PORT2}:7053 -e CORE_LOGGING_LEVEL=debug -e CORE_CHAINCODE_LOGGING_LEVEL=DEBUG -e CORE_CHAINCODE_STARTUPTIMEOUT=900s -e CORE_CHAINCODE_EXECUTETIMEOUT=900s -e CORE_CHAINCODE_DEPLOYTIMEOUT=900s -e CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock -e CORE_PEER_ID=peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com -e CORE_PEER_ADDRESS=peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:7051 -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${NETWORK} -e CORE_PEER_LOCALMSPID=${DEFAULT_ORGANIZATION_NAME}MSP -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/msp -e CORE_LEDGER_STATE_STATEDATABASE=CouchDB -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=${HOST}:${FIRST_ORG_COUCH_DB_PORT} -v /var/run/:/host/var/run/ -v $PWD:/etc/hyperledger/configtx -v $PWD/crypto-config/peerOrganizations/${DEFAULT_ORGANIZATION_NAME}.example.com/peers/peer0.${DEFAULT_ORGANIZATION_NAME}.example.com/msp:/etc/hyperledger/peer/msp -v $PWD/crypto-config/peerOrganizations/${DEFAULT_ORGANIZATION_NAME}.example.com/users:/etc/hyperledger/msp/users --workdir=/opt/gopath/src/github.com/hyperledger/fabric --name=peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com hyperledger/fabric-peer:1.2.1 sh -c 'peer node start'

echo -e "\e[1;35mAll containers created successfully for Your First Organization - ${DEFAULT_ORGANIZATION_NAME}\e[0m";

echo -e "\e[1;35mWait for 5 Seconds to Create and join Peers\e[0m";
sleep 5s

echo -e "\e[1;35mInstall jq and move configtxlator to First Organization.\e[0m";

docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com apt-get update
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com apt-get install jq -y
docker cp configtxlator peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/usr/bin/

echo -e "\e[1;35mCreating a Channel for Your First Organization - ${DEFAULT_ORGANIZATION_NAME}\e[0m";

docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com peer channel create -o ${HOST}:${ORDERER_PORT} -c ${CHANNEL_NAME} -f /etc/hyperledger/configtx/composer-channel.tx

echo -e "\e[1;35mPeer join to the Channel\e[0m";

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${DEFAULT_ORGANIZATION_NAME}.example.com/msp" peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com peer channel join -b ${CHANNEL_NAME}.block

echo -e "\e[1;35mYour Organization Name=${DEFAULT_ORGANIZATION_NAME}\e[0m";
echo -e "\e[1;35mYour Channel Name =${CHANNEL_NAME}\e[0m";
echo -e "\e[1;35mYour First Organization - ${DEFAULT_ORGANIZATION_NAME} Created Successfully.\e[0m";

echo -e "\e[1;35mWait for 5 Seconds to Create Other Organizations\e[0m";
sleep 5s

i=1
for other_org in $(echo $OTHER_ORGANIZATION_NAMES | sed "s/,/ /g")
do
cp configtx.yaml_otherorg_original configtx.yaml
cp crypto-config.yaml_otherorg_original crypto-config.yaml

echo -e "\e[1;35mReplace Configurations in yaml Files for Organization name = ${other_org}\e[0m";
sed -i "s/<Replace_org_name>/$other_org/g" configtx.yaml
sed -i "s/<Replace_org_name>/$other_org/g" crypto-config.yaml

echo -e "\e[1;35mGenerating Certificates for Organization name = ${other_org}\e[0m";

./cryptogen generate --config=crypto-config.yaml
./configtxgen -printOrg ${other_org} > $other_org.json

OTHER_ORG_CA_PORT_VAR=$(echo ${OTHER_ORG_CA_PORT} | cut -d',' -f$i)
OTHER_ORG_COUCH_DB_PORT_VAR=$(echo ${OTHER_ORG_COUCH_DB_PORT} | cut -d',' -f$i)
OTHER_ORG_PEER_PORT1_VAR=$(echo ${OTHER_ORG_PEER_PORT1} | cut -d',' -f$i)
OTHER_ORG_PEER_PORT2_VAR=$(echo ${OTHER_ORG_PEER_PORT2} | cut -d',' -f$i)

echo -e "\e[1;35mCreating CA Container for Organization name = ${other_org}.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${OTHER_ORG_CA_PORT_VAR}:7054 -e other_org=${other_org} -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${NETWORK} -e FABRIC_CA_HOME=/etc/hyperledger/fabric-ca-server -e FABRIC_CA_SERVER_CA_NAME=ca.${other_org}.example.com -v $PWD/crypto-config/peerOrganizations/${other_org}.example.com/ca/:/etc/hyperledger/fabric-ca-server-config --name=ca.${other_org}.example.swarm.com hyperledger/fabric-ca:1.2.1 sh -c 'fabric-ca-server start --ca.certfile /etc/hyperledger/fabric-ca-server-config/ca.${other_org}.example.com-cert.pem --ca.keyfile /etc/hyperledger/fabric-ca-server-config/*_sk -b admin:adminpw -d'

echo -e "\e[1;35mCreating Couchdb Container for Organization name = ${other_org}.\e[0m";

docker run -it -d --network="${NETWORK}" -p ${OTHER_ORG_COUCH_DB_PORT_VAR}:5984 -e 'DB_URL: http://${HOST}:${OTHER_ORG_COUCH_DB_PORT_VAR}/member_db' --name=couchdb-swarm-${OTHER_ORG_COUCH_DB_PORT_VAR} hyperledger/fabric-couchdb:0.4.10

echo -e "\e[1;35mCreating Peer Container for Organization name = ${other_org}\e[0m";

docker run -it -d --network="${NETWORK}" -p ${OTHER_ORG_PEER_PORT1_VAR}:7051 -p ${OTHER_ORG_PEER_PORT2_VAR}:7053 -e CORE_LOGGING_LEVEL=debug -e CORE_CHAINCODE_LOGGING_LEVEL=DEBUG -e CORE_CHAINCODE_STARTUPTIMEOUT=900s -e CORE_CHAINCODE_EXECUTETIMEOUT=900s -e CORE_CHAINCODE_DEPLOYTIMEOUT=900s -e CORE_VM_ENDPOINT=unix:///host/var/run/docker.sock -e CORE_PEER_ID=peer0.${other_org}.example-swarm.com -e CORE_PEER_ADDRESS=peer0.${other_org}.example-swarm.com:7051 -e CORE_VM_DOCKER_HOSTCONFIG_NETWORKMODE=${NETWORK} -e CORE_PEER_LOCALMSPID=${other_org}MSP -e CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/peer/msp -e CORE_LEDGER_STATE_STATEDATABASE=CouchDB -e CORE_LEDGER_STATE_COUCHDBCONFIG_COUCHDBADDRESS=${HOST}:${OTHER_ORG_COUCH_DB_PORT_VAR} -v /var/run/:/host/var/run/ -v $PWD:/etc/hyperledger/configtx -v $PWD/crypto-config/peerOrganizations/${other_org}.example.com/peers/peer0.${other_org}.example.com/msp:/etc/hyperledger/peer/msp -v $PWD/crypto-config/peerOrganizations/${other_org}.example.com/users:/etc/hyperledger/msp/users --workdir=/opt/gopath/src/github.com/hyperledger/fabric --name=peer0.${other_org}.example-swarm.com hyperledger/fabric-peer:1.2.1 sh -c 'peer node start'

echo -e "\e[1;35mAll containers created successfully for Organization name = ${other_org}.\e[0m";
i=$(expr $i + 1)
echo -e "\e[1;35mMoving Organization json file to Default Organization.\e[0m";
docker cp  ${other_org}.json peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
done

echo -e "\e[1;35mUpdate Channel Informations.\e[0m";
rm -rf config.json
rm -rf modified_config.json



for other_org in $(echo $OTHER_ORGANIZATION_NAMES | sed "s/,/ /g")
do
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com peer channel fetch config config_block.pb -o ${HOST}:${ORDERER_PORT} -c ${CHANNEL_NAME}
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com configtxlator proto_decode --input config_block.pb --type common.Block | jq .data.data[0].payload.data.config > config.json
docker cp config.json peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"'$other_org'MSP":.[1]}}}}}' config.json $other_org.json > modified_config.json
docker cp modified_config.json peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com configtxlator proto_encode --input config.json --type common.Config --output config.pb
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com configtxlator proto_encode --input modified_config.json --type common.Config --output modified_config.pb
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com configtxlator compute_update --channel_id ${CHANNEL_NAME} --original config.pb --updated modified_config.pb --output ${other_org}_update.pb
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com configtxlator proto_decode --input ${other_org}_update.pb --type common.ConfigUpdate | jq . > ${other_org}_update.json
docker cp ${other_org}_update.json peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com echo '{"payload":{"header":{"channel_header":{"channel_id":"'$CHANNEL_NAME'", "type":2}},"data":{"config_update":'$(cat ${other_org}_update.json)'}}}' | jq . > ${other_org}_update_in_envelope.json
docker cp ${other_org}_update_in_envelope.json peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com configtxlator proto_encode --input ${other_org}_update_in_envelope.json --type common.Envelope --output ${other_org}_update_in_envelope.pb
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com peer channel signconfigtx -f ${other_org}_update_in_envelope.pb
docker cp  peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/${other_org}_update_in_envelope.pb ${other_org}_update_in_envelope.pb

echo -e "\e[1;35mChannel Signature Process.\e[0m";
org_count=$(echo $OTHER_ORGANIZATION_NAMES | tr ',' ' ' | wc -w)
for (( j=1; j <= $org_count; j++ ))
do
OTHER_ORG_NAME_VAR=$(echo ${OTHER_ORGANIZATION_NAMES} | cut -d',' -f$j)
docker cp ${other_org}_update_in_envelope.pb peer0.${OTHER_ORG_NAME_VAR}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/configtx/crypto-config/peerOrganizations/${OTHER_ORG_NAME_VAR}.example.com/users/Admin@${OTHER_ORG_NAME_VAR}.example.com/msp" -e "CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/configtx/crypto-config/peerOrganizations/${OTHER_ORG_NAME_VAR}.example.com/peers/peer0.${OTHER_ORG_NAME_VAR}.example.com/tls/ca.crt" peer0.${OTHER_ORG_NAME_VAR}.example-swarm.com peer channel signconfigtx -f ${other_org}_update_in_envelope.pb
docker cp peer0.${OTHER_ORG_NAME_VAR}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/${other_org}_update_in_envelope.pb ${other_org}_update_in_envelope.pb 
done

echo -e "\e[1;35mChannel Updation\e[0m";
docker cp ${other_org}_update_in_envelope.pb peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/configtx/crypto-config/peerOrganizations/${DEFAULT_ORGANIZATION_NAME}.example.com/users/Admin@${DEFAULT_ORGANIZATION_NAME}.example.com/msp" -e "CORE_PEER_TLS_ROOTCERT_FILE=/etc/hyperledger/configtx/crypto-config/peerOrganizations/${DEFAULT_ORGANIZATION_NAME}.example.com/peers/peer0.${DEFAULT_ORGANIZATION_NAME}.example.com/tls/ca.crt" peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com peer channel update -f ${other_org}_update_in_envelope.pb -c ${CHANNEL_NAME} -o ${HOST}:${ORDERER_PORT}
done


echo -e "\e[1;35mFetching a Channel information\e[0m";
for other_org in $(echo $OTHER_ORGANIZATION_NAMES | sed "s/,/ /g")
do
docker exec peer0.${other_org}.example-swarm.com peer channel fetch 0 ${CHANNEL_NAME}.block -o ${HOST}:${ORDERER_PORT} -c ${CHANNEL_NAME}
done

echo -e "\e[1;35mPeer join to the Channel\e[0m";
for other_org in $(echo $OTHER_ORGANIZATION_NAMES | sed "s/,/ /g")
do
docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${other_org}.example.com/msp" peer0.${other_org}.example-swarm.com peer channel join -b ${CHANNEL_NAME}.block
done

echo -e "\e[1;35mYour Channel Name =${CHANNEL_NAME}\e[0m";
echo -e "\e[1;35mThe Following Organizations created Successfully.Organization-Names - (${DEFAULT_ORGANIZATION_NAME},$OTHER_ORGANIZATION_NAMES)\e[0m";
