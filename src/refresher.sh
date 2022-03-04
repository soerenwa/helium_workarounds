#!/bin/bash

REGEX='.*(failed to dial (challenger|proxy server|1st hotspot)|dial failed\. Reason:.*, To:) \(?"(\/p2p/[A-Za-z0-9]{40,55})"(:|\):|,)? (timeout_relay_session|not_found|TxnHash:)'

MINER_IMAGE_NAME=$(sudo docker container ls | grep miner | awk 'NF>1{print $NF}')

echo "Starting peer monitor on $MINER_IMAGE_NAME..."

while read LINE;do
    if [[ $LINE =~ $REGEX ]];
    then
        CURRENT_PEER="${BASH_REMATCH[3]}"
        REASON="${BASH_REMATCH[1]}"
        echo "$(date) refreshing \"${CURRENT_PEER}\" due to \"${REASON}\""
        REFRESH_RESULT=$(sudo docker exec -i $MINER_IMAGE_NAME miner peer refresh "$CURRENT_PEER")
    fi

done < <(tail -F /opt/panther-x2/miner_data/log/console.log)
