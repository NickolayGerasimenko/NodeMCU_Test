
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
--station_cfg.ssid="AndroidAP"
--station_cfg.pwd="12345678"

station_cfg.ssid="pooop"
station_cfg.pwd="t4vwn7xt"

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

--wifi.sta.connect(function() 
--    print("connected -----------------")
--    mytimer:start()
--end)

print("Heap 1:"..node.heap())
local dht = require("dht11")
print("Heap 2:"..node.heap())
dht:get_data()
  -- Module can be released when it is no longer needed
dht = nil
package.loaded["dht11"] = nil

print("Heap 3:"..node.heap())

local t = require("ds18b20")
local pin = 3 -- gpio0 = 3, gpio2 = 4
print("Heap 4:"..node.heap())

local function readout(temp)
  if t.sens then
    print("Total number of DS18B20 sensors: ".. #t.sens)
    for i, s in ipairs(t.sens) do
      print(string.format("  sensor #%d address: %s%s",  i, ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(s:byte(1,8)), s:byte(9) == 1 and " (parasite)" or ""))
    end
  end

  for addr, temp in pairs(temp) do
    print(addr)
    print(temp)
    print(string.format("Sensor %s: %s °C", ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(addr:byte(1,8)), temp))
  end

  -- Module can be released when it is no longer needed
  t = nil
  package.loaded["ds18b20"] = nil

  print("Heap 6:"..node.heap())
end

t:read_temp(readout, pin, t.C)

print("Heap 5:"..node.heap())