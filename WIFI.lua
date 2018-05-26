-- Настройка вай фай в режиме ведомой со статическим адресом
wifi.setmode(wifi.STATION)
cfg={}
cfg.ssid="TPS"
cfg.pwd="poporing4516(root)!"
wifi.sta.config(cfg)
cfg={}
cfg.ip="192.168.0.5"
cfg.netmask= "255.255.255.0"
cfg.gateway="192.168.0.2"
wifi.sta.setip(cfg)