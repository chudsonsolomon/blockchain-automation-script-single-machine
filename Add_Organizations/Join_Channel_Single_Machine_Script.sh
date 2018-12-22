#!/bin/bash
# This Script used to Join Organization with existing Channel in Hyperledger Fabric Blockchain Network.
# Replace the following configurations.

# Replace the Orderer Port that you have already created your previous organization. Don't use New Orderer Port.
ORDERER_PORT=<Replace_Orderer_Port>


# Channel Name should be lowercase letters. Don't use numbers or special characters.Specify Previous channel name that you have already created.
CHANNEL_NAME=<Replace_Channel_Name>

# Default Organization Name should be lowercase letters. Don't use numbers or special characters. Don't Specify More than one Organization as default.
DEFAULT_ORGANIZATION_NAME=<Replace_First_Organization_Name>

# Other Organization Names should be lowercase letters. Don't use numbers or special characters.Comma(,) Seperated values for each Organizations.
OTHER_ORGANIZATION_NAMES=<Replace_Other_Organization_Name>

# Replace Host IP Address.
HOST=<Replace_Host_IP_Address>

echo -e "\e[1;35mMake sure you are replace the configurations in script file? Otherwise Press ctrl+c to stop.\e[0m";
echo -e "\e[1;35mSleep for 10 Seconds\e[0m";
sleep 10s


echo -e "\e[1;35mWait for 5 Seconds to Join Other Organizations\e[0m";
sleep 5s

rm -rf config.json
rm -rf modified_config.json



for other_org in $(echo $OTHER_ORGANIZATION_NAMES | sed "s/,/ /g")
do
cp configtx.yaml_original configtx.yaml
cp crypto-config.yaml_original crypto-config.yaml

sed -i "s/<Replace_org_name>/$other_org/g" configtx.yaml
sed -i "s/<Replace_org_name>/$other_org/g" crypto-config.yaml
sed -i "s/<Replace_channel_name>/$CHANNEL_NAME/g" configtx.yaml
sed -i "s/<Replace_orderer_port>/$ORDERER_PORT/g" configtx.yaml

./configtxgen -printOrg ${other_org} > $other_org.json
echo -e "\e[1;35mMoving Organization json file to Default Organization.\e[0m";
docker cp  ${other_org}.json peer0.${DEFAULT_ORGANIZATION_NAME}.example-swarm.com:/opt/gopath/src/github.com/hyperledger/fabric/
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
echo -e "\e[1;35mThe Following Organizations Joined to the channel - ${CHANNEL_NAME} Successfully.Organization-Names - ($OTHER_ORGANIZATION_NAMES)\e[0m";
