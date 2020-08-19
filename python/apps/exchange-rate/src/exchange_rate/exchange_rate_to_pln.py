"""Shows USD/PLN pair based on Polish Central Bank (NBP) fixing exchange rate."""
import xml.etree.ElementTree as ET
import requests


class ExchangeRateToPLN:  # pylint: disable=too-few-public-methods
    """Retrieve exchange rates from Polish NBP."""

    _RATE_TO_PLN_XPATH = './pozycja[kod_waluty="{0}"]/kurs_sredni'
    _NBP_FIXING_DATE = './data_publikacji'
    _NPB_FIXING_URL = 'http://www.nbp.pl/kursy/xml/LastA.xml'

    _nbp_rates_xml = None

    def __init__(self):
        """Retrieve exchange rates from Polish NBP."""
        response = requests.get(self._NPB_FIXING_URL).text
        self._nbp_rates_xml = ET.fromstring(response)

    def get_exchange_rate_to_pln(self, currency='USD'):
        """Get convertion rate for currency."""
        rate = self._nbp_rates_xml.find(self._RATE_TO_PLN_XPATH.format(currency))
        return None if rate is None else rate.text
