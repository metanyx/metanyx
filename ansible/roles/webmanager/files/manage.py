#!/usr/bin/env python
import re
import subprocess
import textwrap
from bottle import get, post, request, run, route, template

usb_count = 2
interfaces_file = '/etc/network/interfaces'

def hostapd_config(iface, ssid, psk, card='edimax', hide=False):
    f = '/etc/hostapd/hostapd.conf'
    if card == 'edimax':
        driver = 'rtl871xdrv'
    else:
        driver = 'nl80211'
    config = textwrap.dedent("""\
        interface=%s
	ssid=%s
	wpa_passphrase=%s
	driver=%s
	hw_mode=g
	channel=6
	macaddr_acl=0
	auth_algs=1
	ignore_broadcast_ssid=0
	wpa=2
	wpa_key_mgmt=WPA-PSK
	wpa_pairwise=TKIP
	rsn_pairwise=CCMP
        """ % (iface, ssid, psk, driver))
    with open(f, "w") as file:
        file.write(config)

def set_wifi_client(ssid, psk, iface='wlan0'):
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

    #TODO set ifaces file:
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


    hostapd_config(iface, ssid, psk, edimax, hide=False)
    service('hostapd', 'restart')
    subprocess.call(["ifup", iface])

    return True

#def config_interface(iface, mode, data, enable=True):
#    subprocess.call(["ifdown", iface])
#    with open(interfaces_file, "r") as interfaces:
#        lines = interfaces.readlines()
#    with open(interfaces_file, "w") as interfaces:
#        for line in lines:
#            if (iface + '_begin') in line:
#
#            interfaces.write(re.sub(r'^    wpa-ssid.*', wpa_ssid, line))
#    with open(interfaces_file, "r") as interfaces:
#        lines = interfaces.readlines()
#    with open(interfaces_file, "w") as interfaces:
#        for line in lines:
#            interfaces.write(re.sub(r'^    wpa-psk.*', wpa_psk, line))
#    subprocess.call(["ifup", iface])



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

@get('/service')
def service(service='tor', state='restart'):
    subprocess.call(["service", service, state])
    return "<p>%sing %s now</p>" % (state, service)

run(host='192.168.5.1', port=80, debug=True)
