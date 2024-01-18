#!/bin/bash
#lightspeed quick lookup and auditing tool
#written by brennan mccown
file="token.config"

if [ -e "$file" ]; then
    token=$(cat token.config)
else
   read -p "Enter Access Code" access_code
   echo $access_code > token.config
fi

get_giftcard_info(){
    read -p "Enter a GiftCard Number: " giftcard_number
    curl --request GET --url https://churchillsgardencenter.vendhq.com/api/2.0/gift_cards/"$giftcard_number" --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
    clear
    current_balance=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"balance"/){print $(i+1)}}}')
    original_balance=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"total_sold"/){print $(i+1)}}}')
    since_redeemed=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"total_redeemed"/){print $(i+1)}}}')
    
    echo -e "Card Number - $giftcard_number\n"
    echo -e "Current Balance - $current_balance\n"
    echo -e "Original Balance - $original_balance\n"
    echo -e "Redeemed Since Bought - $since_redeemed\n"
    read -p "Press Enter to Continue to main Menu" 
    menu
}


menu() {
    clear
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
