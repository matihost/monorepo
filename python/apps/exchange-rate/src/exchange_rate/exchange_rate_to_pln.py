"""Shows USD/PLN pair based on Polish Central Bank (NBP) fixing exchange rate."""
from datetime import date
import json

import xml.etree.ElementTree as ET
import requests
from exchange_rate.helpers.currency import validate_currency_code


class ExchangeRateToPLN:  # pylint: disable=too-few-public-methods
    """Retrieve exchange rates from Polish NBP."""

    __RATE_TO_PLN_XPATH = './pozycja[kod_waluty="{0}"]/kurs_sredni'
    __NPB_FIXING_URL = 'https://static.nbp.pl/dane/kursy/xml/LastA.xml'

    __NBP_API_URL = "http://api.nbp.pl/api/exchangerates/rates/A/{0}/{1}/"

    __nbp_rates_xml = None

    def __init__(self):
        """Retrieve exchange rates from Polish NBP."""
        response = requests.get(self.__NPB_FIXING_URL, timeout=10).text
        self.__nbp_rates_xml = ET.fromstring(response)

    def __get_rate_for_today(self, currency):
        """Get conversion rate for currency for today."""
        currency = validate_currency_code(currency)
        rate = self.__nbp_rates_xml.find(self.__RATE_TO_PLN_XPATH.format(currency))
        return None if rate is None else rate.text

    def __get_rate_for_date(self, currency: str, convert_date: date):
        # TODO handle errors
        currency = validate_currency_code(currency)
        response = requests.get(self.__NBP_API_URL.format(currency, convert_date.isoformat()),
                                headers={'Accept': 'application/json'}, timeout=10).text
        response_json = json.loads(response)
        return str(response_json['rates'][0]['mid'])

    def get_exchange_rate_to_pln(self, currency='USD', convert_date: date = None):
        """Get convertion rate for currency."""
        if convert_date is None:
            return self.__get_rate_for_today(currency)
        return self.__get_rate_for_date(currency, convert_date)
