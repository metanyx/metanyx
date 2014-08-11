#!/usr/bin/env python
import re
import subprocess
from bottle import get, post, request, run, route

def set_wifi(ssid, psk):
    interfaces_file = '/etc/network/interfaces'
    wpa_ssid = '    wpa-ssid ' + ssid
    wpa_psk = '    wpa-psk ' + psk
    subprocess.call(["ifdown", "wlan0"])
    with open(interfaces_file, "r") as interfaces:
        lines = interfaces.readlines()
    with open(interfaces_file, "w") as interfaces:
        for line in lines:
            interfaces.write(re.sub(r'^    wpa-ssid.*', wpa_ssid, line))
    with open(interfaces_file, "r") as interfaces:
        lines = interfaces.readlines()
    with open(interfaces_file, "w") as interfaces:
        for line in lines:
            interfaces.write(re.sub(r'^    wpa-psk.*', wpa_psk, line))
    subprocess.call(["ifup", "wlan0"])
    return True

@route('/')
@get('/setup') # or @route('/setup')
def setup():
    return '''
        <p>TORbone Setup</p>
        <form action="/setup" method="post">
            SSID: <input name="ssid" type="text" /><br>
            WPA PSK: <input name="psk" type="password" /><br>
            <input value="Save" type="submit" />
        </form>
    '''

@post('/setup') # or @route('/login', method='POST')
def do_setup():
    ssid = request.forms.get('ssid')
    psk = request.forms.get('psk')
    if set_wifi(ssid, psk):
        return "<p>SSID and PSK set correctly</p>"
    else:
        return "<p>Setting up WiFi failed</p>"

run(host='192.168.5.1', port=80, debug=True)
