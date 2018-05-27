-- подключаемся к вайфай
dofile ( "WIFI.lua")

-- инициализируем ili9341
dofile ( "disp.lua")

-- инициализируем tm1637
tm1637 = require('tm1637')
tm1637.init(2, 1)
tm1637.set_brightness(2) 

-- Создаем сервер
sv=net.createServer(net.TCP)

-- y глобальная переменная для счета строк по 20 пикселей
y = 20

-- инициализируем пины
gpio.mode(12, gpio.OUTPUT)
gpio.mode(3, gpio.OUTPUT)

-- обработка входящих данных
function receiver(sck, data)   
 
    -- Выводим в терминал UART данные
    print(data)
    
    -- Отправляем копию полученных данных обратно в удаленный терминал
    sck:send("Recived: "..data)
  
    -- считаем строки
    if y == 320 then  
        y = 20
        
        -- после переполнения счетчика очищаем ili9341
        disp:clearScreen()
    end
    
    -- перемещаем позицию на 20 пикселей вниз
    disp:setPrintPos(0, y)
    y = y + 20
    
    -- печатаем данные на дисплее
    disp:print(data)

    -- очищаем TM1637
    tm1637.clear()
    
    -- удаляем ненужные символы в конце строки для печати на TM1637
    local whoami = data
    local res, _ = whoami:gsub("^%s*(.-)%s*$", "%1")

    -- печатаем символы на TM1637
    tm1637.write_string(res)
    
    
    -- disp:print(string.len(data))
    -- возвращает колличество символов в данных

    -- сортируем данные, управляем состоянием пинов esp8266
     if string.sub (data, 0, 3) == "aon" then
          gpio.write(12, gpio.HIGH)
     else
          if string.sub (data, 0, 4) == "aoff" then
               gpio.write(12, gpio.LOW)
          end
     end
     if string.sub (data, 0, 3) == "bon" then
          gpio.write(3, gpio.HIGH)
     else
          if string.sub (data, 0, 4) == "boff" then
               gpio.write(3, gpio.LOW)
          end
     end
end

-- слушаем порт
if sv then
  sv:listen(333, function(conn)
    conn:on("receive", receiver)
    conn:send("Connected")
  end)
end
 
print("Started.")




