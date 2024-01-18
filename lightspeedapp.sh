#!/bin/bash
#lightspeed quick lookup and auditing tool
#written by brennan mccown
file="token.config"
file_2="output.config"
file_3="output_2.config"

if [ -e "$file" ]; then
    token=$(cat token.config)
else
   read -p "Enter Access Code" access_code
   echo $access_code > token.config
fi
clear
if [ -e "$file_2" ]; then
    rm -irf "$file_2"
else
    sleep 0
fi
if [ -e "$file_3" ]; then
    rm -irf "$file_3"
else
    sleep 0
fi

get_outlet_id_from_sku(){
    if [ -e "$file_2" ]; then
        rm -irf "$file_2"
    else
        sleep 0
    fi 
    if [ -n "$sku" ]; then

        ### find out how to get outlet ID
        outlet_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"product_id"/){print $(i+1)}}}' | sed 's/"//g')     
    else
        clear
        echo "An Error as Occured.. Returning to Main Menu"
        menu
    fi
}

get_product_id_from_sku(){
    if [ -e "$file_2" ]; then
        rm -irf "$file_2"
    else
        sleep 0
    fi
    if [ -n "$sku" ]; then
        curl --request GET --url 'https://churchillsgardencenter.vendhq.com/api/2.0/search?type=products&sku='$sku'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
        product_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"product_id"/){print $(i+1)}}}' | sed 's/"//g')
    else
    clear
    echo "An error has occured.. Returning to main menu"
    menu
    fi
}

inventory_quantity_alteration(){
    clear
    read -p "Enter a SKU: " sku
    get_product_id_from_sku
    if [ -n "$product_id" ]; then
        clear
        read -p "Enter the Current Inventory QTY: " inv_current
        curl --request PUT --url https://churchillsgardencenter.vendhq.com/api/2.1/products/"$product_id" --header 'accept: application/json' --header 'authorization: Bearer '$token'' --header 'content-type: application/json' --data '{ "details": { "inventory": [ { "current_amount": '$inv_current' } ] } }'
    else
        echo "An Error has occured.. Returning to Main Menu"
    fi

}

transaction_search_for_giftcard(){
    #curl --request GET --url 'https://churchillsgardencenter.vendhq.com/api/2.0/search?type=products&sku=608666746050' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output_2.config
    sleep 0
}

get_giftcard_info(){
    read -p "Enter a GiftCard Number: " giftcard_number
    curl --request GET --url https://churchillsgardencenter.vendhq.com/api/2.0/gift_cards/"$giftcard_number" --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
    clear
    current_balance=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"balance"/){print $(i+1)}}}' | sed 's/"//g')
    original_balance=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"total_sold"/){print $(i+1)}}}' | sed 's/"//g')
    since_redeemed=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"total_redeemed"/){print $(i+1)}}}' | sed 's/"//g')
    creation_date=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"created_at"/){print $(i+1)}}}' | sed 's/"//g')
    status=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"created_at"/){print $(i+1)}}}' | sed 's/"//g')


    echo -e "Card Number: $giftcard_number\n"
    echo -e "Current Balance: $current_balance\n"
    echo -e "Original Balance: $original_balance\n"
    echo -e "Redeemed Since Bought: $since_redeemed\n"
    echo -e "Creation Date: $creation_date"
    echo -e "Status: $status"

    read -p "Press Enter to Continue to main Menu" 
    rm -irf output.config
    menu
}

menu() {
    clear
    echo "[1] Get GiftCard Info"
    echo "[2] Inventory QTY Changes"

    read -p "Select an Option: " choice
    
    if [ "$choice" = "1" ]; then
        get_giftcard_info
    elif [ "$choice" = "2" ]; then
        inventory_quantity_alteration
    else
        echo Invalid Option
        sleep 2
        menu
    fi
    
}

menu
