---
-- @description Driver for 4-digit 7-segment displays controlled by TM1637 chip
-- @date September 08, 2016
-- @author ovoronin
-- @date March 15, 2017
-- @author heendebak
---
--------------------------------------------------------------------------------

local M = {}
local I2C_COMM1 = 0x40
local I2C_COMM2 = 0xC0
local cmd_power_on = 0x88
local pin_clk
local pin_dio
local brightness = 0x0f
local power = cmd_power_on

--[[ 
  Character creation:
      A
     ---
   F | | B
     -G-
   E | | C
     ---
      D
     XGFEDCBA
   0b00111111 => 0
   0b00000110 => 1
     00011011  
   Add character and hex-value to table alphabet
--]]

local alphabet = {
  ["0"] = 0x3F,
  ["1"] = 0x06,
  ["2"] = 0x5B,
  ["3"] = 0x4F,
  ["4"] = 0x66,
  ["5"] = 0x6D,
  ["6"] = 0x7D,
  ["7"] = 0x07,
  ["8"] = 0x7F,
  ["9"] = 0x6F,
  ["A"] = 0x77,
  ["B"] = 0x7C,
  ["C"] = 0x39,
  ["D"] = 0x5E,
  ["E"] = 0x79,
  ["F"] = 0x71,
  ["G"] = 0x3D,
  ["H"] = 0x74,
  ["I"] = 0x30,
  ["J"] = 0x1E,
  ["K"] = 0x75,
  ["L"] = 0x38,
  ["M"] = 0x15,
  ["N"] = 0x54,
  ["O"] = 0x5C,
  ["P"] = 0x73,
  ["Q"] = 0x67,
  ["R"] = 0x50,
  ["S"] = 0x2D,
  ["T"] = 0x78,
  ["U"] = 0x3E,
  ["V"] = 0x1C,
  ["W"] = 0x2A,
  ["X"] = 0x76,
  ["Y"] = 0x6E,
  ["Z"] = 0x1B,
  [" "] = 0x00
   
}
local _dot = 0x80
local _nilchar = 0x40

local function clk_high()
  gpio.write(pin_clk, gpio.HIGH)
end

local function clk_low()
  gpio.write(pin_clk, gpio.LOW)
end

local function dio_high()
  gpio.write(pin_dio, gpio.HIGH)
end

local function dio_low()
  gpio.write(pin_dio, gpio.LOW)
end

local function i2c_start()
  clk_high()
  dio_high()
  tmr.delay(2)
  dio_low()
end

local function i2c_ack ()
  clk_low()
  dio_high()
  tmr.delay(5)

  gpio.mode(pin_dio, gpio.INPUT)
  while ( gpio.read(pin_dio) == gpio.HIGH) do
  end
  gpio.mode(pin_dio, gpio.OUTPUT)

  clk_high()
  tmr.delay(2)
  clk_low()
end

local function i2c_stop()
  clk_low()
  tmr.delay(2)
  dio_low()
  tmr.delay(2)
  clk_high()
  tmr.delay(2)
  dio_high()
end

local function i2c_write(b)
  for i = 0, 7, 1
  do
    clk_low()
    if bit.band(b, 1) == 1 then
      dio_high()
    else
      dio_low()
    end
    tmr.delay(3)
    b = bit.rshift(b, 1)
    clk_high()
    tmr.delay(3)
  end
end

local function _clear()
 i2c_start()
    i2c_write(I2C_COMM2)
    i2c_ack()
    i2c_write(0)
    i2c_ack()
    i2c_write(0)
    i2c_ack();
    i2c_write(0)
    i2c_ack()
    i2c_write(0)
    i2c_ack()
  i2c_stop()
end

local function init_display()
    i2c_start()
    i2c_write(I2C_COMM1)
    i2c_ack()
    i2c_stop()
    _clear()
    i2c_write(cmd_power_on + brightness)
end

local function write_byte(b, pos)
    i2c_start()
    i2c_write(I2C_COMM2 + pos)
    i2c_ack()
    i2c_write(b)
    i2c_ack()
    i2c_stop()
end

function M.init(clk, dio)
    pin_clk = clk
    pin_dio = dio

    gpio.mode(pin_dio, gpio.OUTPUT)
    gpio.mode(pin_clk, gpio.OUTPUT)

    init_display()
end

function M.set_brightness(b)
  if b > 7 then b = 7 end
  brightness = bit.band(b, 7)

  i2c_start()
  i2c_write( power + brightness )
  i2c_ack()
  i2c_stop()
end

function M.write_string(str)
  local pos = 3
  local i = #str
  local dot = false

  str = string.upper(str)

  while (i >= 1) and (pos >= 0) do
    local s = str:sub(i,i)
    if s == '.' then
      dot = true
      i = i - 1
      s = str:sub(i,i)
    end

    local bt = alphabet[s]

    if (bt == nil) then bt = _nilchar end
    if dot then bt = bt + _dot end

    write_byte(bt, pos)
    pos = pos - 1
    i = i - 1
  end
end

function M.clear()
  _clear()
end

return M