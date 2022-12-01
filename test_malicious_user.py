""" This is a python file which will send malicious user requests to the lb and fetch detected malicious user events from F5 XC console """

import os
import sys
import json
import time
import requests
from art import *
from tqdm import tqdm
from requests.structures import CaseInsensitiveDict


# user inputs
user_input = json.load(open('./user_inputs.json', 'r'))
tenant_api = user_input["api_url"]
ns_name = user_input["namespace"]
token = user_input["api_token"]
headers = CaseInsensitiveDict()
headers["Accept"] = "application/json"
headers["Authorization"] = "APIToken " + token
lb_domain = user_input["domain"]


print(text2art("F5 XC Automation", font="small"))


def validate_deploy(secure=False):
    """ 
    The function will check the reachability of load balancer 
    
    Parameter:
    secure (Boolean): request protocol HTTP[False]/HTTPS[True]    
    """
    git_env = os.getenv('GITHUB_ENV')
    if secure:
        # try/except block to handle connection exception 
        try:
            req = requests.get("https://{}".format(lb_domain), verify=False, timeout=5)
            # verification of request's reponse code
            if req.status_code != 200:
                print('Request status code not equal to 200')
                with open(git_env, "a") as bashfile:
                    bashfile.write("EXIT=true")
            else:
                print('Request to https lb is successful')
                with open(git_env, "a") as bashfile:
                    bashfile.write("EXIT=false")
        except requests.exceptions.ConnectionError:
            print('https://{} is not reachable (Exception raised)'.format(lb_domain))
            with open(git_env, "a") as bashfile:
                bashfile.write("EXIT=true")
    else:
        # try/except block to handle connection exception 
        try:
            req = requests.get("http://{}".format(lb_domain), timeout=5)
            # verification of request's reponse code
            if req.status_code != 200:
                print('Request status code not equal to 200')
                with open(git_env, "a") as bashfile:
                    bashfile.write("EXIT=true")
            else:
                print('Request to http lb is successful')
                with open(git_env, "a") as bashfile:
                    bashfile.write("EXIT=false")
        except requests.exceptions.ConnectionError:
            print('http://{} is not reachable (Exception raised)'.format(lb_domain))
            with open(git_env, "a") as bashfile:
                bashfile.write("EXIT=true")


def get_tor_session():
    """ The function will return a SOCKS Proxy session """
    session = requests.session()
    # tor uses 9050 port as a default socks port
    session.proxies = {'http': 'socks5://127.0.0.1:9050',
                       'https': 'socks5://127.0.0.1:9050'}
    return session


def tor_requests():
    """ The function will generate tor requests """
    session = get_tor_session()
    print("============= Pumping Tor Requests =============")
    for reqs in tqdm(range(0, 50), desc="tor requests"):
        session.get("http://{}".format(lb_domain))
        time.sleep(1)


def xss_attack():
    """ The function will generate XSS attack """
    print("============= XSS =============")
    for reqs in tqdm(range(0, 50), desc="XSS"):
        requests.get("https://{}?<script>var a = 1;</script>".format(lb_domain), verify=False)
        time.sleep(1)


def fetch_mal_usr_event(tenant_api, ns_name):
    """
    The function will fetch the malicious user event logs from F5 XC console

    Parameters:
    tenant_api (String): F5 XC tenant api url 
    ns_name (String): Application namespace

    Returns:
    json: malicious user event logs
    """
    url = "{0}/data/namespaces/{1}/app_security/suspicious_user_logs".format(tenant_api, ns_name)                                                                                                                 
    event = requests.post(url, headers=headers)
    return event.json()


def mal_user_timeline():
    """ The function will print malicious user detection and mitigation logs """
    output = fetch_mal_usr_event(tenant_api, ns_name)
    print("\n======= F5 XC Malicious user event logs =======\n")

    for i in range(len(output['logs'])):
        d = json.loads(output['logs'][i])
        print(d['summary_msg'])

    print("============================================== ")


def main():
    if sys.argv[1] == "secure" and sys.argv[2] == "True":
        # function call to validate reachability of https lb
        time.sleep(30)
        validate_deploy(True)
    elif sys.argv[1] == "secure" and sys.argv[2] == "False":
        # function call to validate reachability of http lb
        time.sleep(10)
        validate_deploy()
    elif sys.argv[1] == "tor":
        # function call to generate tor requests
        time.sleep(10)
        tor_requests()
        time.sleep(30)
        mal_user_timeline()
    else:
        # function call to generate XSS 
        time.sleep(10)
        xss_attack()
        time.sleep(30)
        mal_user_timeline()        
        

        
if __name__ == "__main__":
    main()
