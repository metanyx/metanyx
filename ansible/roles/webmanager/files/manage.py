#!/usr/bin/env python
import re
import subprocess
from bottle import get, post, request, run, route, template

usb_count = 2

def set_wifi_client(ssid, psk, iface='wlan0'):
    interfaces_file = '/etc/network/interfaces'
    wpa_ssid = '    wpa-ssid ' + ssid
    wpa_psk = '    wpa-psk ' + psk
    subprocess.call(["ifdown", iface])
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
    subprocess.call(["ifup", iface])
    return True

# TODO: Make this work
def set_wifi_ap(ssid, psk, iface='wlan1'):
    interfaces_file = '/etc/network/interfaces'
    subprocess.call(["ifdown", iface])
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
    subprocess.call(["ifup", iface])
    return True


@route('/')
@get('/setup') # or @route('/setup')
def setup():
    return template('setup_template', usb_count=usb_count)

@post('/setup')
def do_setup():
    ssid = request.forms.get('ssid')
    psk = request.forms.get('psk')
    wlan0 = request.forms.get('wlan0')
    if set_wifi_client(ssid, psk):
        return '<p>SSID and PSK set correctly.<br><a href="setup">Menu</a></p>'
    else:
        return '<p>Setting up WiFi failed.<br><a href="setup">Menu</a></p>'

@get('/shutdown')
def shutdown():
    subprocess.call(["shutdown", "now", "-h"])
    return "<p>Shuting down system now</p>"

@get('/reboot')
def reboot():
    subprocess.call(["reboot"])
    return "<p>Rebooting system now</p>"

run(host='192.168.5.1', port=80, debug=True)
