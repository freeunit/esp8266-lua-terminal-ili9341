-- подключаемся к вайфай
dofile ( "WIFI.lua")

-- инициализируем дисплей
dofile ( "disp.lua")

-- Создаем сервер
sv=net.createServer(net.TCP)

-- y глобальная переменная для счета строк по 20 пикселей
y = 20

-- инициализируем пины
gpio.mode(1, gpio.OUTPUT)
gpio.mode(2, gpio.OUTPUT)

-- обработка входящих данных
function receiver(sck, data)   
 
    -- Выводим в терминал UART данные
    print(data)
    
    -- Отправляем копию полученных данных обратно
    sck:send("Recived: "..data)
  
    -- считаем строки
    if y == 320 then  
        y = 20
        
        -- после переполнения счетчика очищаем дисплей
        disp:clearScreen()
    end
    
    -- перемещаем курсор на следующую строку
    disp:setPrintPos(0, y)
    y = y + 20
    
    -- печатаем данные на дисплее
    disp:print(data)
    
    -- disp:print(string.len(data))
    -- возвращает колличество символов в данных

    -- сортируем данные, управляем состоянием пинов
     if string.sub (data, 0, 3) == "aon" then
          gpio.write(1, gpio.HIGH)
     else
          if string.sub (data, 0, 3) == "aof" then
               gpio.write(1, gpio.LOW)
          end
     end
     if string.sub (data, 0, 3) == "bon" then
          gpio.write(2, gpio.HIGH)
     else
          if string.sub (data, 0, 3) == "bof" then
               gpio.write(2, gpio.LOW)
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




