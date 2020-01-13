wifi.setmode(wifi.STATION)

function sendData(temperature)
    -- conection to thingspeak.com
    print("Sending data to thingspeak.com")
    conn=net.createConnection(net.TCP, 0) 
    conn:on("receive", function(conn, payload) print(payload) end)
    -- api.thingspeak.com 184.106.153.149
    conn:connect(80,thinkspeak_IP) 
    conn:send("GET /update?key="..thinkspeak_API_key.."&field1="..temperature.." HTTP/1.1\r\n") 
    conn:send("Host: api.thingspeak.com\r\n") 
    conn:send("Accept: */*\r\n") 
    conn:send("User-Agent: Mozilla/4.0 (compatible; esp8266 Lua; Windows NT 5.1)\r\n")
    conn:send("\r\n")
    conn:on("sent",function(conn)
                          print("Closing connection to thingspeak.com")
                          conn:close()
                      end)
            
    conn:on("disconnection", function(conn)
                          print("Got disconnection...")
      end)
end


station_cfg={}
--station_cfg.ssid="AndroidAP"
--station_cfg.pwd="12345678"

station_cfg.ssid="MikroTik-642A2E"
station_cfg.pwd="t4vwn7xt"


thinkspeak_IP = '184.106.153.149'
thinkspeak_URL = "/update.json"
thinkspeak_API_key = '7G6SB6VVV60348F3' 

station_cfg.save=false
station_cfg.auto=false
wifi.sta.config(station_cfg)
connected = 0

local _1_sec = 1000
local _1_min = 60*_1_sec
local send_period = 20*_1_min

use_dht11 = false
use_ds18b20 = true

mytimer = tmr.create()
mytimer:register(10000, tmr.ALARM_SEMI, function() 
    if(wifi.sta.getip() ~= nil) then
        mytimer:stop() 
        mytimer:unregister()
        
        if use_dht11 then
            if not tmr.create():alarm(send_period, tmr.ALARM_AUTO, function()
                print("Heap 1:"..node.heap())
                local dht = require("dht11")
                print("Heap 2:"..node.heap())
                dht:send_thingspeak() 
                  -- Module can be released when it is no longer needed
                dht = nil
                package.loaded["dht11"] = nil
                end)
            then
                print("whoopsie")
            end
        end

        if use_ds18b20 then
            if not tmr.create():alarm(send_period, tmr.ALARM_AUTO, function()
            
                print("Heap 3:"..node.heap())
                local t = require("ds18b20")
                print("Heap 4:"..node.heap())
                
                local function readout(temp)
                    if t.sens then
                        print("Total number of DS18B20 sensors: ".. #t.sens)
                        for i, s in ipairs(t.sens) do
                            print(string.format("  sensor #%d address: %s%s",  i, ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(s:byte(1,8)), s:byte(9) == 1 and " (parasite)" or ""))
                        end
                    end
                
                    for addr, temp in pairs(temp) do
                        print(string.format("Sensor %s: %s °C", ('%02X:%02X:%02X:%02X:%02X:%02X:%02X:%02X'):format(addr:byte(1,8)), temp))
                        sendData(temp)
                    end
                
                    -- Module can be released when it is no longer needed
                    t = nil
                    package.loaded["ds18b20"] = nil
                
                    print("Heap 6:"..node.heap())
                end
                local pin = 3 -- gpio0 = 3, gpio2 = 4
                t:read_temp(readout, pin, t.C)
                
                print("Heap 5:"..node.heap())
                end)
            then
                print("whoopsie")
            end
        end
    else 
        mytimer:start()
    end
    print(wifi.sta.getip()) 
end)
--mytimer:interval(3000) -- actually, 3 seconds is better!

wifi.sta.connect(function() 
    print("WIFI connection established -----------------")
    wifi.sta.getap(function (t)
      for ssid,v in pairs(t) do
        authmode, rssi, bssid, channel = 
        string.match(v, "(%d),(-?%d+),(%x%x:%x%x:%x%x:%x%x:%x%x:%x%x),(%d+)")
        print(ssid,authmode,rssi,bssid,channel)
      end
    end)
    if not mytimer:start() then print("Unable to start timer!") end
end)
