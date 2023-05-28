local require = require("../require")
local item_delivery_request_channel = table.unpack(require("../channel"))
local location_str, item_str, count = ...

if location_str == nil or item_str == nil or count == nil then
    error("Usage: mrm <location> <item> <count>")
end

local modem = peripheral.find("modem")
if modem == nil then
    print("Computer must have modem")
end

location_str = location_str:lower()
item_str = item_str:lower()
count = tonumber(count)
if count == nil then
    error("Count must be a number")
end

modem.transmit(item_delivery_request_channel, 0, { location_str, item_str, count })

print("Dispatching train to", location_str, "for", count, "of", item_str)