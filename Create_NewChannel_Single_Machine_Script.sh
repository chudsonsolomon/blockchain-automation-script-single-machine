#!/bin/bash
# This Script used to Create New Channel and join with Default Hyperledger Fabric Blockchain Network.
# Replace the following configurations.

# Replace the Orderer Port that you have already created your previous organization. Don't use New Orderer Port.
ORDERER_PORT=<Replace_Orderer_Port>


# Channel Name should be lowercase letters. Don't use numbers or special characters.Specify New channel name.
CHANNEL_NAME=<Replace_Channel_Name>

# Default Organization Name should be lowercase letters. Don't use numbers or special characters. Don't Specify More than one Organization as default.
DEFAULT_ORGANIZATION_NAME=<Replace_Organization_Name>

# Replace Host IP Address.
HOST=<Replace_Host_IP_Address>

echo -e "\e[1;35mMake sure you are replace the configurations in script file? Otherwise Press ctrl+c to stop.\e[0m";
echo -e "\e[1;35mSleep for 10 Seconds\e[0m";
sleep 10s

echo -e "\e[1;35mGenerating Channel Configtx file.\e[0m";
cp configtx.yaml_original configtx.yaml
cp crypto-config.yaml_original crypto-config.yaml

sed -i "s/<Replace_org_name>/$DEFAULT_ORGANIZATION_NAME/g" configtx.yaml
sed -i "s/<Replace_org_name>/$DEFAULT_ORGANIZATION_NAME/g" crypto-config.yaml
sed -i "s/<Replace_channel_name>/$CHANNEL_NAME/g" configtx.yaml
sed -i "s/<Replace_orderer_port>/$ORDERER_PORT/g" configtx.yaml

./configtxgen -profile ${CHANNEL_NAME} -outputCreateChannelTx ./composer-channel.tx -channelID ${CHANNEL_NAME}
./configtxgen -profile ComposerOrdererGenesis -outputBlock ./composer-genesis.block


echo -e "\e[1;35mWait for 5 Seconds to Create Channel and join Organizations.\e[0m";
sleep 5s

echo -e "\e[1;35mInstall jq and move configtxlator to First Organization.\e[0m";

docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com apt-get update
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com apt-get install jq -y
docker cp configtxlator peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/usr/bin/

echo -e "\e[1;35mCreating a Channel - ${DEFAULT_ORGANIZATION_NAME}\e[0m";
docker cp composer-channel.tx peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker cp composer-genesis.block peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
docker exec peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com peer channel create -o ${HOST}:${ORDERER_PORT} -c ${CHANNEL_NAME} -f composer-channel.tx

echo -e "\e[1;35mPeer join to the Channel\e[0m";

docker exec -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${DEFAULT_ORGANIZATION_NAME}.example.com/msp" peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com peer channel join -b ${CHANNEL_NAME}.block

echo -e "\e[1;35mYour Organization Name=${DEFAULT_ORGANIZATION_NAME}\e[0m";
echo -e "\e[1;35mYour Channel Name =${CHANNEL_NAME}\e[0m";
echo -e "\e[1;35mYour Default Organization - ${DEFAULT_ORGANIZATION_NAME} Joined to the New Channel - ${CHANNEL_NAME} Successfully.\e[0m";
