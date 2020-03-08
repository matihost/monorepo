#!/usr/bin/env python3
"""
Shows USD/PLN pair based on Polish Central Bank (NBP) fixing exchange rate.
"""
import xml.etree.ElementTree as ET
import requests

RATE_TO_PLN_XPATH = './pozycja[kod_waluty="{0}"]/kurs_sredni'
NPB_FIXING_URL = 'http://www.nbp.pl/kursy/xml/LastA.xml'

def get_exchange_rate_to_pln(currency):
    """
    Get convertion rate for currency
    """
    response = requests.get(NPB_FIXING_URL).text
    xml = ET.fromstring(response)
    return xml.find(
        RATE_TO_PLN_XPATH.format(currency)
    ).text

if __name__ == "__main__":
    print('1 USD = {0} PLN'.format(get_exchange_rate_to_pln('USD')))
