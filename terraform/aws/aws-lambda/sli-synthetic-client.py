#!/usr/bin/env python3
"""Emulate a client by calling directly EC2 instance."""
import os
import sys
import json
import logging
# AWS Lambda does not ship requests out of the box
# import requests
import urllib3

# Global configuration
logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s', level=logging.INFO)
http = urllib3.PoolManager()


def test_ec2_via_http(ip):
    """Call EC2 via HTTP."""
    try:
        r = http.request('GET', 'http://{0}'.format(ip), timeout=3.5, retries=0)
        response = r.data.decode('utf-8')
        if logging.getLogger().isEnabledFor(logging.DEBUG):
            logging.debug('Correct response: %s...', response[:20])
        return (200 <= r.status < 300, r.status, response)
    except urllib3.exceptions.HTTPError as err:
        err_string = str(err)
        logging.error('Encountered error while accessing %s: %s ', ip, err_string)
        return (False, 500, err_string)


def lambda_handler(event, context):
    """Entrypoint to AWS lambda execution."""
    ip_to_test = os.environ["IP_TO_TEST"]
    status, code, text = test_ec2_via_http(ip_to_test)
    # Lamda response should follow:
    # https://aws.amazon.com/premiumsupport/knowledge-center/malformed-502-api-gateway/
    # in order to be consumable via API Gateway
    return {
        'statusCode': code,
        'isBase64Encoded': False,
        'body': json.dumps({'status': status, 'text': text})
    }


def main():
    """Enter the program to test it locally."""
    # given
    ip_to_test = sys.argv[1]

    # when
    test_result = test_ec2_via_http(ip_to_test)

    # then
    logging.info("Status: {0}, Code: {1}, Text: {2}".format(*test_result))


if __name__ == "__main__":
    main()
