import os
import subprocess as sp
import time as t
import math
import requests as r

token = "lsxs_pt_DqunywZS9wzFNhYaqNlIwuiPtIyJEd4L"

def clear():
    os.system('cls' if os.name == 'nt' else 'clear')

def product_updating():
    clear()
    product_identifier = input ("Enter a product SKU to be updated: ")
    clear()


    url = "https://domain_prefix.vendhq.com/api/2.1/products/%s" % token

    headers = {
        "accept": "application/json",
        "content-type": "application/json",
        "authorization": "Bearer %s" % token
   
    }

    response = r.put(url, headers=headers)

    print(response.text)

def get_giftcard_info():
    clear()
    card_num = input("Input a Card Number: ")

    url = "https://domain_prefix.vendhq.com/api/2.0/gift_cards?card_number=%s&status=ACTIVE" % card_num

    headers = {
    "accept": "application/json",
    "authorization": "Bearer lsxs_pt_DqunywZS9wzFNhYaqNlIwuiPtIyJEd4L"
    }

    response = r.get(url, headers=headers)

    print(response.text)


def menu():
    clear()
    print("[1] Get Giftcard info")
    print("[2] Update a Product")

menu()
