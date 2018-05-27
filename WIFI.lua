-- Настройка вай фай в режиме ведомой со статическим адресом
wifi.setmode(wifi.STATION)
cfg={}
cfg.ssid="WIFI"
cfg.pwd="password"
wifi.sta.config(cfg)
cfg={}
cfg.ip="192.168.0.2"
cfg.netmask= "255.255.255.0"
cfg.gateway="192.168.0.1"
wifi.sta.setip(cfg)
