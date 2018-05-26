    print ( "Waiting ...")
    -- Делаем задержку на загрузку файла, чтоб если что не так успеть перезаписаться
tmr.register(0, 5000, tmr.ALARM_SINGLE, 
    function (t)
    tmr.unregister (0);
    print ( "Starting ...");
    dofile ( "main.lua")
    end
)
tmr.start (0)
