"""
Shows USD/PLN pair based on Polish Central Bank (NBP) fixing exchange rate.
"""
import xml.etree.ElementTree as ET
import requests


class ExchangeRateToPLN:
    _RATE_TO_PLN_XPATH = './pozycja[kod_waluty="{0}"]/kurs_sredni'
    _NBP_FIXING_DATE = './data_publikacji'
    _NPB_FIXING_URL = 'http://www.nbp.pl/kursy/xml/LastA.xml'

    def get_exchange_rate_to_pln(self, currency):
        """
        Get convertion rate for currency
        """
        response = requests.get(self._NPB_FIXING_URL).text
        xml = ET.fromstring(response)
        rate = xml.find(self._RATE_TO_PLN_XPATH.format(currency))
        return None if rate is None else rate.text
