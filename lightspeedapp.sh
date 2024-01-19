#!/bin/bash
#lightspeed quick lookup and auditing tool
#written by brennan mccown
file="token.config"
file_2="output.config"
file_3="output_2.config"
file_4="domain.config"

if [ -e "$file" ]; then
    token=$(cat token.config)
else
   clear
   echo -e "You Will Only Need to do this once\n"
   read -p "Enter Access Code: " access_code
   echo $access_code > token.config
fi
if [ -e "$file_4" ]; then
    domain_prefix=$(cat domain.config)
else
   clear
   echo -e "You Will Only Need to do this once\n"
   read -p "Enter Domain Prefix: " domain_chosen
   echo $domain_chosen > domain.config
fi
clear
if [ -e "$file_2" ]; then
    rm -irf "$file_2"
else
    true
fi
if [ -e "$file_3" ]; then
    rm -irf "$file_3"
else
    true
fi

find_customer_id_through_tests(){
    if [ -e "$file_2" ];then
        rm -irf "$file_2"
    else
        true
    fi
    clear
    read -p "Enter Customer Phone Number: " phone_number_for_id_search
    if [ -n "$phone_number_for_id_search" ]; then
        if [ -e "$file_2" ];then
            rm -irf "$file_2"
        else
            true
        fi
        curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/search?type=customers&phone='$phone_number_for_id_search'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
        if grep -q "$phone_number_for_id_search" "$file_2"; then
            return_customer_id_from_tests=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
        else
            clear 
            echo "No Customer Found under "$phone_number_for_id_search" Try an email"
            read -p "Enter a Customer Email: " email_for_id_search
            if [ -n "$email_for_id_search" ]; then
                if [ -e "$file_2" ];then
                    rm -irf "$file_2"
                else
                    true
                fi
                curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/search?type=customers&email='$email_for_id_search'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
                if grep -q "$email_for_id_search" "$file_2"; then
                    return_customer_id_from_tests=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
                else
                    clear
                    echo "No Customer Found under "$email_for_id_search" Try a Last Name"
                    read -p "Enter a Customer Last Name: " last_name_for_id_search
                    if [ -n "$last_name_for_id_search" ]; then
                        if [ -e "$file_2" ];then
                            rm -irf "$file_2"
                        else
                            true
                        fi
                        curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/search?type=customers&last_name='$last_name_for_id_search'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
                        if grep -q "$email_for_id_search" "$file_2"; then
                            return_customer_id_from_tests=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
                        else
                            clear
                            echo "No Customer Found under "$last_name_for_id_search" Try a Customer Code"
                            read -p "Enter a Customer Code: " customer_code_for_id_search
                            if [ -n "$customer_code_for_id_search" ]; then
                                if [ -e "$file_2" ];then
                                    rm -irf "$file_2"
                                else
                                    true
                                fi
                                curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/search?type=customers&customer_code='$customer_code_for_id_search'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
                                return_customer_id_from_tests=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
                                if [ -n "$return_customer_id_from_tests" ]; then
                                    pass=true
                                else
                                    echo "An Error has Occured.. Returning to Main Menu"
                                    menu
                                fi
                            fi
                        fi    
                    fi
                fi
            else
            echo "An Error has Occured.. Returning to Main Menu"  
            menu  
            fi    
        fi
    else
        echo "An Error has Occured.. Returning to Main Menu"
        menu
    fi
}

customer_search_by_parameter(){
    if [ -e "$file_2" ];then
        rm -irf "$file_2"
    else
        true
    fi
    clear
    echo "[1] Search by Phone Number"
    echo "[2] Search by Email"
    echo "[3] Search by Last Name"
    echo -e "[4] Search by Customer Code\n"
    
    read -p "Choose an Option: " choice_2
    if [ "$choice_2" = "1" ]; then
        clear
        read -p "Enter a Phone Number: " phone_number_for_search

        if [ -n "$phone_number_for_search" ]; then
            curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/search?type=customers&phone='$phone_number_for_search'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
            return_customer_name=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"name"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g') 
            return_customer_code=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"customer_code"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g') 
            return_customer_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
            clear
            echo "Customer Name: "$return_customer_name
            echo "Customer Code: "$return_customer_code
            echo -e "Customer ID:   "$return_customer_id"\n"
            read -p "Press Enter To Return To Main Menu.."                           
        else
            echo "An Error has Occured.. Returning to Main Menu"
            sleep 2
            menu
        fi
    elif [ "$choice_2" = "2" ]; then
        clear
        read -p "Enter an Email: " email_for_search

        if [ -n "$email_for_search" ]; then
            curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/search?type=customers&email='$email_for_search'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
            return_customer_name=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"name"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g') 
            return_customer_code=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"customer_code"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g') 
            return_customer_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
            clear
            echo "Customer Name: "$return_customer_name
            echo "Customer Code: "$return_customer_code
            echo -e "Customer ID:   "$return_customer_id"\n"
            read -p "Press Enter To Return To Main Menu.."  
        else
            echo "An Error has Occured.. Returning to Main Menu"
            sleep 2
            menu
        fi
    elif [ "$choice_2" = "3" ]; then
        clear
        read -p "Enter a Last Name: " last_name_for_search

        if [ -n "$last_name_for_search" ]; then
            curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/search?type=customers&last_name='$last_name_for_search'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
            return_customer_name=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"name"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g') 
            return_customer_code=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"customer_code"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g') 
            return_customer_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
            clear
            echo "Customer Name: "$return_customer_name
            echo "Customer Code: "$return_customer_code
            echo -e "Customer ID:   "$return_customer_id"\n" 
            read -p "Press Enter To Return To Main Menu.." 
        else
            echo "An Error has Occured.. Returning to Main Menu"
            sleep 2
            menu
        fi
    elif [ "$choice_2" = "4" ]; then
        clear
        read -p "Enter a Customer Code: " customer_code_for_search
    
        if [ -n "$customer_code_for_search" ]; then
            curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/search?type=customers&customer_code='$customer_code_for_search'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
            return_customer_name=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"name"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g') 
            return_customer_code=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"customer_code"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g') 
            return_customer_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
            clear
            echo "Customer Name: "$return_customer_name
            echo "Customer Code: "$return_customer_code
            echo -e "Customer ID:   "$return_customer_id"\n" 
            read -p "Press Enter To Return To Main Menu.." 
        else
            echo "An Error has Occured.. Returning to Main Menu"
            sleep 2
            menu
        fi
    else
        echo "An Error has Occured.. Returning to Main Menu"
        sleep 2
        menu
    fi 
}

get_outlet_id_from_sku(){
    if [ -e "$file_2" ]; then
        rm -irf "$file_2"
    else
        true
    fi 
    if [ -n "$sku" ]; then
        curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/outlets' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
        outlet_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')     
    else
        clear
        echo "An Error as Occured.. Returning to Main Menu"
        sleep 2
        menu
    fi
}

get_product_id_from_sku(){
    if [ -e "$file_2" ]; then
        rm -irf "$file_2"
    else
        true
    fi
    if [ -n "$sku" ]; then
        curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/search?type=products&sku='$sku'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
        product_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"product_id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
    else
    clear
    echo "An error has occured.. Returning to main menu"
    sleep 2
    menu
    fi
}

inventory_quantity_alteration(){
    clear
    read -p "Enter a SKU: " sku
    get_product_id_from_sku
    get_outlet_id_from_sku
    if [ -n "$product_id" ]; then
        clear
        read -p "Enter the Current Inventory QTY: " inv_current
        curl --request PUT --url 'https://'$domain_prefix'.vendhq.com/api/2.1/products/'$product_id'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' --header 'content-type: application/json' --data ' { "details": { "inventory": [ { "outlet_id": "'$outlet_id'", "current_amount": '$inv_current' } ] } }' > response.config
        check_response=$(cat response.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"current_amount"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
        if [ "$check_response" -eq "$inv_current" ]; then
            clear 
            echo "Inventory Updated"
            read -p "Press Enter to Continue to Main Menu" 
            menu
        else
            clear
            echo "An Error has Occured.. Returning to Main Menu"
            sleep 2
            menu
        fi
    else
        echo "An Error has occured.. Returning to Main Menu"
        sleep 2
        menu
    fi

}

add_or_subtract_inventory_quantity(){
    #devlope
    true
}

#trying to figure out loyalty adjustment. possibly need to connect customer code in order to adjust? use customer id to search for customer code then add into post

get_customer_code(){
    if [ -n "$return_customer_id_from_tests" ]; then
        curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/customers/'$return_customer_id_from_tests'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
        get_customer_code_from_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"customer_code"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
    else
        echo "No Customer ID"
        echo "An Error Has Occured.. Returning to Main Menu"
        sleep 2
        menu
    fi
}

alter_customer_loyalty(){
    find_customer_id_through_tests
    get_customer_code
    if [ -n "$return_customer_id_from_tests" ]; then
        clear
        read -p "Enter a Positive or Negative Loyalty Adjustment: " loyalty_adjust
        curl --request POST --url 'https://'$domain_prefix'.vendhq.com/api/customers' \
            --header 'accept: application/json' \
            --header 'authorization: Bearer '$token'' \
            --header 'content-type: application/json' \
            --data '
                    {
                        "customer_code": "'$get_customer_code_from_id'",
                        ...
                        "enable_loyalty": 1,
                        "loyalty_adjustment": "'$loyalty_adjust'",
                        ...
                    }
                    '
    else
        echo "An Error has Occured.. Returning to Main Menu"
        sleep 2
        menu
    fi
}

transaction_search_for_giftcard(){
    #curl --request GET --url 'https://"$domain_prefix".vendhq.com/api/2.0/search?type=products&sku=608666746050' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output_2.config
    true
}

display_giftcard_info(){
    clear
    if [ -n "$return_register_name_for_giftcard" ]; then
        echo "Register of Transaction: "$return_register_name_for_giftcard
    else
        true
    fi
    if [ -n "$return_person_name_for_giftcard" ]; then
        echo "Employee: "$return_person_name_for_giftcard
    else
        true
    fi
    if [ -n "$return_customer_name_for_giftcard" ]; then
        echo "Customer: "$return_customer_name_for_giftcard
    else
        true
    fi
    if [ -n "$giftcard_original_sale_invoice_number" ]; then
        echo "Invoice Number: "$giftcard_original_sale_invoice_number
    else
        true
    fi
    if [ -n "$giftcard_purchase_transaction_type" ]; then
        echo -e "Transaction Type: "$giftcard_purchase_transaction_type"\n"
    else
        true
    fi
    read -p "Press Enter To Continue To Main Menu" 
    menu
}

get_details_for_giftcard_sale_info(){
    if [ -e "$file_2" ]; then
        rm -irf $file_2
    else
        true
    fi
    if [ -n "$giftcard_sold_on_register" ]; then
        curl --request GET \
             --url 'https://'$domain_prefix'.vendhq.com/api/2.0/registers/'$giftcard_sold_on_register'' \
             --header 'accept: application/json' \
             --header 'authorization: Bearer '$token'' > output.config
             return_register_name_for_giftcard=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"name"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
    else
        false
    fi
    if [ -n "$giftcard_sold_by_person" ]; then
        curl --request GET \
             --url 'https://'$domain_prefix'.vendhq.com/api/2.0/users/'$giftcard_sold_by_person'' \
             --header 'accept: application/json' \
             --header 'authorization: Bearer '$token'' > output.config
             return_person_name_for_giftcard=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"display_name"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')           
    else
        false
    fi
    if [ -n "$giftcard_sold_to_customer" ]; then
        curl --request GET \
             --url 'https://'$domain_prefix'.vendhq.com/api/2.0/customers/'$giftcard_sold_to_customer'' \
             --header 'accept: application/json' \
             --header 'authorization: Bearer '$token'' > output.config
             return_customer_name_for_giftcard=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"display_name"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
    else
        false
    fi
    if [ -n "$giftcard_original_sale_invoice_number" ]; then
        curl --request GET \
             --url 'https://'$domain_prefix'.vendhq.com/api/2.0/sales/'$giftcard_original_sale_invoice_number'' \
             --header 'accept: application/json' \
             --header 'authorization: Bearer '$token''
             return_receipt_number_for_giftcard=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"receipt_number"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
    else
        false
    fi
    display_giftcard_info
}

gift_card_sale_info(){
    clear
    if [ -e "$file_2" ]; then
        rm -irf $file_2
    else
        true
    fi
    if [ -n "$return_giftcard_sale_id" ]; then
        curl --request GET \
            --url 'https://'$domain_prefix'.vendhq.com/api/2.0/sales/'$return_giftcard_sale_id'' \
            --header 'accept: application/json' \
            --header 'authorization: Bearer '$token'' > output.config 
            #returns register id
            giftcard_sold_on_register=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"register_id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
            #returns employee user id
            giftcard_sold_by_person=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"user_id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
            #returns customer id
            giftcard_sold_to_customer=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"customer_id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')     
            #returns invoice number
            giftcard_original_sale_invoice_number=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"receipt_number"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
            #returns transaction id
            giftcard_transaction_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"transaction_id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')    
            #returns transaction type
            giftcard_purchase_transaction_type=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"name"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
            get_details_for_giftcard_sale_info
    else
        echo "An Erorr has Occured.. Returning to Main Menu"
        menu
    fi
}

get_giftcard_info(){
    clear
    read -p "Enter a GiftCard Number: " giftcard_number
    curl --request GET --url 'https://'$domain_prefix'.vendhq.com/api/2.0/gift_cards/'$giftcard_number'' --header 'accept: application/json' --header 'authorization: Bearer '$token'' > output.config
    clear
    current_balance=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"balance"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
    original_balance=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"total_sold"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
    since_redeemed=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"total_redeemed"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
    creation_date=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"created_at"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
    status=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"status"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')
    return_giftcard_sale_id=$(cat output.config | awk -F'[:,]' '{for(i=1;i<=NF;i++){if($i~/"sale_id"/){print $(i+1)}}}' | sed 's/"//g' | sed 's/}//g')

    echo -e "Card Number: $giftcard_number"
    echo -e "Current Balance: $current_balance"
    echo -e "Original Balance: $original_balance"
    echo -e "Redeemed Since Bought: $since_redeemed"
    echo -e "Creation Date: $creation_date"
    echo -e "Status: $status\n"

    echo "[1] Sale Information"
    echo -e "[2] Return to Main Menu\n"
    read -p "Select an Option: " option
    if [ "$option" = "1" ]; then
        gift_card_sale_info
    elif [ "$option" = "2" ]; then
        menu
    else
        menu
    fi
    rm -irf output.config
    menu
}

menu() {
    clear
    if [ -e "$file_2" ]; then
        rm -irf $file_2
    else
        true
    fi
    echo "[1] Get GiftCard Info"
    echo "[2] Inventory QTY Changes"
    echo "[3] Customer Search by Parameter"
    echo "[4] Alter Customer Loyalty (Beta)"

    read -p "Select an Option: " choice
    
    if [ "$choice" = "1" ]; then
        get_giftcard_info
    elif [ "$choice" = "2" ]; then
        inventory_quantity_alteration
    elif [ "$choice" = "3" ]; then
        customer_search_by_parameter
    elif [ "$choice" = "4" ]; then
        alter_customer_loyalty
    else
        echo Invalid Option
        sleep 2
        menu
    fi
    
}

menu
