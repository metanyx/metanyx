<!doctype html>  

<head>  
  <meta charset="utf-8">  
  <title>metanyx administration</title>  
  <meta name="metanyx" content="Welcome to metanyx.">  
  <link rel="stylesheet" href="static/style.css?v=1">  
</head>  
  
<body>  

  <div id="wrapper">  
    <header>  
      <h1>metanyx administration</h1>  
      <nav>  
        <ul>  
          <li><a rel="external" href="setup">Setup</a></li>  
          <li><a rel="external" href="status">Status</a></li>  
+           <li><a rel="external" href="update">Update</a></li>
          <li><a rel="external" href="https://metanyx.net" target="new">About</a></li>  
          <li><a rel="external" href="shutdown">Shutdown</a></li>  
          <li><a rel="external" href="reboot">Reboot</a></li>  
          <li><a rel="external" href="service">Restart Tor</a></li>  
          <li><a rel="external" href="https://check.torproject.org" target="new">Tor Check</a></li>  
        </ul>  
      </nav>  
    </header>  
          
    <div id="core">
      <p>
        Battery status: {{ batt_status }} <br>
        Battery capacity: {{ batt_capacity }}%
      </p>
 

    </div>

  </div>

</body>
</html>
