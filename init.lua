
wifi.setmode(wifi.STATION)

-- print ap list
function listap(t)
      print("------------------------------ listap")
      for ssid,v in pairs(t) do
        authmode, rssi, bssid, channel = 
        string.match(v, "(%d),(-?%d+),(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x),(%d+)")
        print(ssid,authmode,rssi,bssid,channel)
      end
end

--wifi.sta.getap(listap)

station_cfg={}
station_cfg.ssid="AndroidAP"
station_cfg.pwd="12345678"
station_cfg.save=false
station_cfg.auto=false
wifi.sta.config(station_cfg)
connected = 0

mytimer = tmr.create()
mytimer:register(10000, tmr.ALARM_SEMI, function() 
    if(wifi.sta.getip() ~= nil) then
        print("stop timer")
        mytimer:stop() 
        mytimer:unregister() 
    else 
        mytimer:start()
    end
    print(wifi.sta.getip()) 
end)
mytimer:interval(3000) -- actually, 3 seconds is better!

wifi.sta.connect(function() 
    print("connected -----------------")
    mytimer:start()
end)

print("dsasadasdsad")