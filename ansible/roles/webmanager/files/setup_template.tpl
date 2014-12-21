<p>metanyx setup</p>
<form action="/setup" method="post">

    <label>Ethernet</label>
    <br>
    <input type="radio" name="eth0" id="dhcp_server" value="dhcp_server" checked="checked"/>
    <label for="dhcp_server">DHCP Server</label>
    <input type="radio" name="eth0" id="static_server" value="static_server" />
    <label for="static_server">Static IP Server</label>
    <input type="radio" name="eth0" id="client" value="client" />
    <label for="client">DHCP client</label>
    <br><br>

    <label>wlan0</label>
    <br>
    <input type="radio" name="wlan0" id="AP" value="AccessPoint" />
    <label for="AP">Access Point</label>
    <input type="radio" name="wlan0" id="client" value="Client" checked="checked" />
    <label for="client">client</label>

    %if usb_count > 1:
    <br><br>
    <label>wlan1</label>
    <br>
    <input type="radio" name="wlan1" id="AP" value="AccessPoint" checked="checked"/>
    <label for="AP">Access Point</label>
    <input type="radio" name="wlan1" id="client" value="Client" />
    <label for="client">client</label>
    %end

    <br><br>
    WiFi authentication details (To connect to an AP - if used):<br>
    SSID: <input name="ssid" type="text" /><br>
    WPA PSK: <input name="psk" type="password" /><br>
    <br>

    <br>
    WiFi Access Point credentials (if used):<br>
    SSID: <input name="ssid" type="text" /><br>
    Hidden SSID: <input name="hidden_ssid" type="checkbox" /><br> 
    WPA PSK: <input name="psk" type="password" /><br>
    <br>

    <input value="Save" type="submit" />
</form>

<p>
  <a href="shutdown">Shutdown</a>
  <a href="reboot">Reboot</a>
  <a href="https://check.torproject.org" target="new">Tor Check</a>
</p>

<p>To implement next:<br> 
new tor ID, change password, various diagnostic and status pages, change mac address, 3g, change hostname</p>
