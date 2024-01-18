#!/bin/bash

token="lsxs_pt_h9OPozjbJpgm2WiNFnzMY1Oh8V034tjM"

get_giftcard_info(){
    read -p "Enter a GiftCard Number: " giftcard_number
    curl --request GET \
     --url https://churchillsgardencenter.vendhq.com/api/2.0/gift_cards/"$giftcard_number" \
     --header 'accept: application/json' \
     --header 'authorization: Bearer lsxs_pt_h9OPozjbJpgm2WiNFnzMY1Oh8V034tjM'
}


menu() {
    echo "[1] Get GiftCard Info"
    read -p "Select an Option: " choice
    
    if [ "$choice" = "1" ]; then
        get_giftcard_info
    else
        echo Invalid Option
        menu
    fi
    
}

menu