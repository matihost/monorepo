#!/usr/bin/env python3
"""
Show Foreign Currency/PLN pair.

It is based on Polish Central Bank (NBP) fixing exchange rate.
"""
from datetime import date
import logging
from waitress import serve
from flask import Flask, jsonify, make_response

from exchange_rate.helpers.version import package_version
from exchange_rate.helpers.currency import validate_currency_code
from exchange_rate.exchange_rate_to_pln import ExchangeRateToPLN


app = Flask(__name__)
logger = logging.getLogger('waitress')
logger.setLevel(logging.INFO)

_DESCRIPTION = "Shows Foreign Currency/PLN pair based on Polish \
Central Bank (NBP) fixing exchange rate."


@app.route("/exchanges/<currency>/<convert_date>")
def exchanges(currency, convert_date):
    """Expose /exchanges GET endpoint."""
    rate_to_pln = ExchangeRateToPLN().get_exchange_rate_to_pln(
        validate_currency_code(currency), date.fromisoformat(convert_date))
    return jsonify({"currency": currency, "rate_to_pln": rate_to_pln, "date": convert_date})


@app.route('/about')
def about():
    """Expose /about GET endpoint."""
    response = make_response(_DESCRIPTION)
    response.mimetype = 'text/plain'
    return response


@app.route('/version')
def version():
    """Expose /version GET endpoint."""
    return package_version('exchange-rate')


def main():
    """Enter the program."""
    # app.run(host='0.0.0.0', port=8080)
    serve(app, host="0.0.0.0", port=8080)


if __name__ == "__main__":
    main()
