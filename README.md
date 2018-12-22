# Blockchain-Automation-Script-Single-Machine:
This script used to automate Hyperledger Fabric Blockchain Network creation. Create Single Organization Default Hyperledger Blockchain Network. Adding Peers for extending first Organization. Adding Organizations in Existing Hyperledger Fabric Blcokchain Network. Adding Peers for extending Other Organizations. Create Multi Organization Hyperledger Blockchain Network. Create New Channel in Existing Hyperledger Fabric Network. Join Organizations with Existing Channel in Hyperledger Fabric Network. Create Multi Orderer Kafka Hyperledger Fabric Blockchain Network.

Contents:
---------
    - Create Single Organization Default Hyperledger Blockchain Network. (Default_BlockChain_Network_Script.sh)
    - Adding Peers for extending first Organization. (Add_Peers_in_Default_Blockchain_Network.sh)
    - Adding Organizations in Existing Hyperledger Fabric Blcokchain Network (Add_Org_in_Existing_Blockchain_Network.sh)
    - Adding Peers for extending Other Organizations.For Organization2,Organization3,... (Add_Peers_in_Extended_Organizations.sh)
    - Create Multi Organization Hyperledger Blockchain Network.(Multi_Organization_Single_Machine_Script.sh)
    - Create New Channel in Existing Hyperledger Fabric Network. (Create_NewChannel_Single_Machine_Script.sh)
    - Join Organizations with Existing Channel in Hyperledger Fabric Network.(Join_Channel_Single_Machine_Script.sh)
    - Create Multi Orderer Kafka Hyperledger Fabric Blockchain Network.(Multi_Orderer_Kafka_Script.sh)
    
How To Run:
----------
Clone Repository:
-----------------
Clone this repository to get the latest using the following command.

    - git clone https://github.com/chudsonsolomon/blockchain-automation-script-single-machine.git.
    - cd blockchain-automation-script-single-machine.
    - cp configtxgen configtxlator cryptogen Add_Organizations/
    - cp configtxgen configtxlator cryptogen Multi_Orderer_Kafka/
    - cp configtxgen configtxlator cryptogen Multi_Organizations/
 
Create Single Organization Default Network Hyperledger BlockChain Network:
-------------------------------------------------------------------------
1. Read Prerequisites_Notes and follow steps to Initializae Docker Swarm and Network Creation in Your Host.
2. sudo chmod 777 Default_BlockChain_Network_Script.sh
3. Open "Default_BlockChain_Network_Script.sh" script file using your favourite editor, Then Replace the Following Configurations.
    - Network Name
    - CA_Port
    - Orderer_Port
    - CouchDB_Port
    - Peer_Port1
    - Peer_Port2
    - Channel_Name
    - Organization_Name
    - Replace_Host_IP_Address
 4. Save and Close the Script File. Make Sure You have replaced all <Replace_Tag> in Script Files.
 5. Run the Script File.
    ./Default_BlockChain_Network_Script.sh
 6. This Script Creates the Single Organization Hyperledger-Fabric Blockchain Network.
        This Script Creates Following Containers in your Host.
      - 1 Peer Container
      - 1 CA Container
      - 1 Orderer Container
      - 1 CouchDB Container.
 7. The Default Hyperledger Blockchain Network Created Successfully in Your Host.

Adding New Peers with your Existing Hyperledger fabric Blockchain Network:
-------------------------------------------------------------------------
Note:
-----
    - Use this Script for only first organization.
    
 1. Open "Add_Peers_in_Default_Blockchain_Network.sh" script file using your favourite editor,Then Replace the Following Configurations.
 
 2. Replace Network name that you have already created environment.Don't use new Network name.
      - NETWORK=<Replace_Network_Name>
    
 3. Replace Orderer Port which you have created already.
      - ORDERER_PORT=<Replace_Orderer_Port>
    
 4. Replace Couchdb New Port for New Peer.
      - COUCH_DB_PORT=<Replace_CouchDB_Port>
    
 5. Replace Peer Count number.If you have already created 2 peers for corresponding Organization then You can specify the count as 3.
      - PEER_COUNT_NUMBER=<Replace_Peer_Count>
    
 6. Replace Peer Port. Make sure you doesn't use this port previously.
     - PEER_PORT1 is used to connecting the peers(Port_NO:7051)
     - PEER_PORT2 is used to event hub services(Port_NO:7053)
     - PEER_PORT1=<Replace_Peer_Port1>
     - PEER_PORT2=<Replace_Peer_Port2>
            
 7. Replace the channel name that you have already created. Don't Replace with New Channel name.
     - CHANNEL_NAME=<Replace_Channel_Name>
        
 8. Replace the organization name that you have already created. Don't Replace with New organization name.
     - ORGANIZATION_NAME=<Replace_Organization_Name>

 9. Replace Host IP Address.
     - HOST=<Replace_Host_IP_Address>
        
 10. Save and Close the Script File. Make Sure You have replaced all <Replace_Tag> in Script Files.
 
 11. Run the Script File.
    ./Add_Peers_in_Default_Blockchain_Network.sh   
    
 12. This Script Creates the Peer and Join with Existing Hyperledger-Fabric Blockchain Network.
 
 13. New Peer added successfully with Existing Hyperledger-Fabric Blockchain Network.


Adding New Organizations with your Existing Hyperledger fabric Blockchain Network:
---------------------------------------------------------------------------------
 1. cd Add_Organizations
 2. Open "Add_Org_in_Existing_Blockchain_Network.sh" script file using your favourite editor,Then Replace the Following Configurations.
 3. Replace the network name that you have already created your previous organizations.
      - NETWORK=<Replace_Network_Name>

 4. Replace CA Port. Make sure You doesn't use this port previously.
      - CA_PORT1=<Replace_CA_Port>

 5. Replace the Orderer Port that you have already created your previous organization. Don't use New Orderer Port.
      - ORDERER_PORT=<Replace_Orderer_Port>

 6. Replace CouchDB Port. Make sure You doesn't use this port previously.
      - COUCH_DB_PORT=<Replace_CouchDB_Port>

 7. Replace Peer Port. Make sure You doesn't use this port previously.
      - PEER_PORT1 is used to connecting the peers(Port_NO:7051)
      - PEER_PORT2 is used to event hub services(Port_NO:7053)
      - PEER_PORT1=<Replace_Peer_Port1>
      - PEER_PORT2=<Replace_Peer_Port2>

 8. Channel Name should be lowercase letters. Don't use numbers or special characters.
      - CHANNEL_NAME=<Replace_Channel_Name>

 9. Organization Name should be lowercase letters. Don't use numbers or special characters.
      - ORGANIZATION_NAME=<Replace_Organization_Name>
      - FIRST_ORGANIZATION_NAME=<Replace_First_Organization_Name>

 10. Replace Host IP Address.
      - HOST=<Replace_Host_IP_Address>

 11. If you have already more than one organization Please specify Previous organization names except first organization.(comma(,)     seperated value). Otherwise leave it blank.
      - PREVIOUS_ORGANIZATIONS=<Replace Previous_Organization_Names>
      - Example: PREVIOUS_ORGANIZATIONS= organization1,organization2
 12. Save and Close the Script File. Make Sure You have replaced all <Replace_Tag> in Script Files.
 13. Run the Script File.
       - ./Add_Org_in_Existing_Blockchain_Network.sh
 14. This Script Creates the Single Organization Hyperledger-Fabric Blockchain Network.
        This Script Creates Following Containers in your Host.
      - 1 Peer Container
      - 1 CA Container
      - 1 CouchDB Container.
 15. New Organization added and joining successfully with Existing Hyperledger-Fabric Blockchain Network.
    
Add New Peers with your Extended Organizations:
----------------------------------------------
Note:
-----
    - Use this Script for only Extended organizations.For Organization2,Organization3,...(Don't use this script for first organization.)
    
 1. cd Add_Organizations
 2. Open "Add_Peers_in_Extended_Organizations.sh" script file using your favourite editor,Then Replace the Following Configurations.
 
 3. Replace Network name that you have already created environment.Don't use new Network name.
      - NETWORK=<Replace_Network_Name>
    
 4. Replace Orderer Port which you have created already.
      - ORDERER_PORT=<Replace_Orderer_Port>
    
 5. Replace Couchdb New Port for New Peer.
      - COUCH_DB_PORT=<Replace_CouchDB_Port>
    
 6. Replace Peer Count number.If you have already created 2 peers for corresponding Organization then You can specify the count as 3.
      - PEER_COUNT_NUMBER=<Replace_Peer_Count>
    
 7. Replace Peer Port. Make sure you doesn't use this port previously.
     - PEER_PORT1 is used to connecting the peers(Port_NO:7051)
     - PEER_PORT2 is used to event hub services(Port_NO:7053)
     - PEER_PORT1=<Replace_Peer_Port1>
     - PEER_PORT2=<Replace_Peer_Port2>
            
 8. Replace the channel name that you have already created. Don't Replace with New Channel name.
     - CHANNEL_NAME=<Replace_Channel_Name>
        
 9. Replace the organization name that you have already created. Don't Replace with New organization name.
      - ORGANIZATION_NAME=<Replace_Organization_Name>   

 10. Replace Host IP Address.
      - HOST=<Replace_Host_IP_Address>
   
 11. Save and Close the Script File. Make Sure You have replaced all <Replace_Tag> in Script Files.
 
 12. Run the Script File.
    ./Add_Peers_in_Extended_Organizations.sh   
    
 13. This Script Creates the Peer and Join with Existing Hyperledger-Fabric Blockchain Network.
 
 14. New Peer added successfully with Existing Hyperledger-Fabric Blockchain Network.


Create Multi Organization Hyperledger Blockchain Network:
--------------------------------------------------------
 1. cd Multi_Organizations
 2. Open "Multi_Organization_Single_Machine_Script.sh" script file using your favourite editor,Then Replace the Following                   Configurations.
 3. Replace the network name that you have already created with Docker Swarm.
      - NETWORK=<Replace_Network_Name>

 4. Replace First Org CA Port. Make sure You doesn't use this port previously. Specify only one port for first org CA Port.
      - FIRST_ORG_CA_PORT=<Replace_FIRST_ORG_CA_Port>
      
 5. Replace Other Org CA Port. Make sure You doesn't use this port previously.Comma(,) Seperated values for each Organizations.
      - OTHER_ORG_CA_PORT=<Replace_OTHER_ORG_CA_Port>

 6. Replace the Orderer Port.Make sure You doesn't use this port previously.
      - ORDERER_PORT=<Replace_Orderer_Port>

 7. Replace First Org CouchDB Port. Make sure You doesn't use this port previously.Specify only one port for first org Couch_DB Port.
      - FIRST_ORG_COUCH_DB_PORT=<Replace_FIRST_ORG_CouchDB_Port>
      
 8. Replace Other Org CouchDB Port. Make sure You doesn't use this port previously.Comma(,) Seperated values for each Organizations.
      - OTHER_ORG_COUCH_DB_PORT=<Replace_OTHER_ORG_CouchDB_Port>

 9. Replace First Org Peer Ports. Make sure You doesn't use this port previously.Specify only one port for first org Peer Port.
      - PEER_PORT1 is used to connecting the peers(Port_NO:7051)
      - PEER_PORT2 is used to event hub services(Port_NO:7053)
      - FIRST_ORG_PEER_PORT1=<Replace_FIRST_ORG_Peer_Port1>
      - FIRST_ORG_PEER_PORT2=<Replace_FIRST_ORG_Peer_Port2>
      
 10. Replace Other Org Peer Ports. Make sure You doesn't use this port previously. Comma(,) Seperated values for each Organizations.
      - PEER_PORT1 is used to connecting the peers(Port_NO:7051)
      - PEER_PORT2 is used to event hub services(Port_NO:7053)
      - OTHER_ORG_PEER_PORT1=<Replace_OTHER_ORG_Peer_Port1>
      - OTHER_ORG_PEER_PORT2=<Replace_OTHER_ORG_Peer_Port2>

 11. Channel Name should be lowercase letters. Don't use numbers or special characters.
      - CHANNEL_NAME=<Replace_Channel_Name>

 12. Default Organization Name should be lowercase letters. Don't use numbers or special characters. Don't Specify More then one Organization as default.
      - DEFAULT_ORGANIZATION_NAME=<Replace_First_Organization_Name>
      
 13. Other Organization Names should be lowercase letters. Don't use numbers or special characters.Comma(,) Seperated values for each Organizations.
      - OTHER_ORGANIZATION_NAMES=<Replace_Other_Organizations_Name>

 14. Replace Host IP Address.
      - HOST=<Replace_Host_IP_Address>

 14. Save and Close the Script File. Make Sure You have replaced all <Replace_Tag> in Script Files.
 
 15. Run the Script File.
       - ./Multi_Organization_Single_Machine_Script.sh
       
 16. Multi Organization Hyperledger-Fabric Blockchain Network Created Successfully.

 
Create New Channel in Existing Hyperledger Fabric Network:
---------------------------------------------------------
 1. Open "Create_NewChannel_Single_Machine_Script.sh" script file using your favourite editor,Then Replace the Following Configurations.
 
 2. Replace the Orderer Port that you have already created your previous organization. Don't use New Orderer Port.
       - ORDERER_PORT=<Replace_Orderer_Port>
       
 3. Replace Channel Name should be lowercase letters. Don't use numbers or special characters.Specify New channel name.
       - CHANNEL_NAME=<Replace_Channel_Name>
       
 4. Replace Default Organization Name should be lowercase letters. Don't use numbers or special characters. Don't Specify More than one     Organization as default.
       - DEFAULT_ORGANIZATION_NAME=<Replace_Organization_Name>

 5. Replace Host IP Address.
       - HOST=<Replace_Host_IP_Address>
       
Note:
-----   
      - If You have created your Hyperledger Fabric Network using Multiorganization Script, then use the following script to create New Channel.
      
 1. cd Multi_Organizations
 
 2. Open "Create_NewChannel_Single_Machine_Script.sh" script file using your favourite editor,Then Replace the Following Configurations.
 
 3. Replace the Orderer Port that you have already created your previous organization. Don't use New Orderer Port.
       - ORDERER_PORT=<Replace_Orderer_Port>
       
 4. Replace Channel Name should be lowercase letters. Don't use numbers or special characters.Specify New channel name.
       - CHANNEL_NAME=<Replace_Channel_Name>
       
 5. Replace Default Organization Name should be lowercase letters. Don't use numbers or special characters. Don't Specify More than one     Organization as default.
       - DEFAULT_ORGANIZATION_NAME=<Replace_Organization_Name>

 6. Replace Host IP Address.
       - HOST=<Replace_Host_IP_Address>

       
Join Organizations with Existing Channel in Hyperledger Fabric Network:
----------------------------------------------------------------------
 1. cd Add_Organizations
 
 2. Open "Join_Channel_Single_Machine_Script.sh" script file using your favourite editor,Then Replace the Following Configurations.
 
 3. Replace the Orderer Port that you have already created your previous organization. Don't use New Orderer Port.
       - ORDERER_PORT=<Replace_Orderer_Port>
       
 4. Replace Channel Name should be lowercase letters. Don't use numbers or special characters.Specify New channel name.
       - CHANNEL_NAME=<Replace_Channel_Name>
       
 5. Replace Default Organization Name should be lowercase letters. Don't use numbers or special characters. Don't Specify More than one     Organization as default.
       - DEFAULT_ORGANIZATION_NAME=<Replace_Organization_Name>
       
 6. Other Organization Names should be lowercase letters. Don't use numbers or special characters.Comma(,) Seperated values for each         Organizations.
       - OTHER_ORGANIZATION_NAMES=<Replace_Other_Organization_Name>

 7. Replace Host IP Address.
       - HOST=<Replace_Host_IP_Address>
       
Note:
-----   
      - If You have created your Hyperledger Fabric Network using Multiorganization Script, then use the following script to join Organizations with New Channel.
      
 1. cd Multi_Organizations
 
 2. Open "Join_Channel_Single_Machine_Script.sh" script file using your favourite editor,Then Replace the Following Configurations.
 
 3. Replace the Orderer Port that you have already created your previous organization. Don't use New Orderer Port.
       - ORDERER_PORT=<Replace_Orderer_Port>
       
 4. Replace Channel Name should be lowercase letters. Don't use numbers or special characters.Specify New channel name.
       - CHANNEL_NAME=<Replace_Channel_Name>
       
 5. Replace Default Organization Name should be lowercase letters. Don't use numbers or special characters. Don't Specify More than one     Organization as default.
       - DEFAULT_ORGANIZATION_NAME=<Replace_Organization_Name>
       
 6. Other Organization Names should be lowercase letters. Don't use numbers or special characters.Comma(,) Seperated values for each         Organizations.
       - OTHER_ORGANIZATION_NAMES=<Replace_Other_Organization_Name>

 7. Replace Host IP Address.
       - HOST=<Replace_Host_IP_Address>


Create Multi Orderer Kafka Hyperledger Fabric Blockchain Network:
----------------------------------------------------------------

 1. cd Multi_Orderer_Kafka

 2. Open "Multi_Orderer_Kafka_Script.sh" script file using your favourite editor,Then Replace the Following Configurations.

 3. Replace Zookeeper Port. Make sure you doesn't use this port previously. Comma(,) Seperated values for each Orderers.
      - ZOOKEEPER_PORTS=<Replace_Zookeeper_Port>

 4. Replace Kafka Port. Make sure you doesn't use this port previously. Comma(,) Seperated values for each Orderers.Kafka Ports count should be same as Zookeeper Ports. If you specify 3 zookeeper ports,then you must specify 3 kafka ports.
      - KAFKA_PORTS=<Replace_Kafka_Port>

 5. Replace the network name that you have already created your previous organizations.
      - NETWORK=<Replace_Network_Name>

 6. Replace CA Port. Make sure You doesn't use this port previously.
      - CA_PORT1=<Replace_CA_Port>

 7. Replace Orderer Port. Make sure you doesn't use this port previously. Comma(,) Seperated values for each Orderers.
      - ORDERER_PORT=<Replace_Orderer_Port>

 8. Replace CouchDB Port. Make sure You doesn't use this port previously.
      - COUCH_DB_PORT=<Replace_CouchDB_Port>

 9. Replace Peer Port. Make sure You doesn't use this port previously.
      - PEER_PORT1 is used to connecting the peers(Port_NO:7051)
      - PEER_PORT2 is used to event hub services(Port_NO:7053)
      - PEER_PORT1=<Replace_Peer_Port1>
      - PEER_PORT2=<Replace_Peer_Port2>

 10. Channel Name should be lowercase letters. Don't use numbers or special characters.
      - CHANNEL_NAME=<Replace_Channel_Name>

 11. Organization Name should be lowercase letters. Don't use numbers or special characters.
      - ORGANIZATION_NAME=<Replace_Organization_Name>

 12. Replace Host IP Address.
      - HOST=<Replace_Host_IP_Address>

 13. Save and Close the Script File. Make Sure You have replaced all <Replace_Tag> in Script Files.

 14. Run the Script File.
       - ./Multi_Orderer_Kafka_Script.sh

 15. Multi Orderer Kafka Hyperledger Fabric Blockchain Network Created Successfully.
