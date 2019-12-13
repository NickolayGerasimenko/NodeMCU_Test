esptool --port COM4 erase_flash

esptool --port COM4 write_flash -fm dio 0x00000 F:\ESPlorer\nodemcu-master-14-modules-2019-12-13-15-16-32-float.bin