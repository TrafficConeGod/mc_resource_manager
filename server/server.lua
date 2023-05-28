local require = require("../require")
local item_delivery_request_channel, warehouse_manifest_channel, get_channel_for_location_name, get_location_name_for_channel = table.unpack(require("../channel"))
local location_names_lookup = require("location_names_lookup")
local item_names_lookup = require("../item_names_lookup")

local modem = peripheral.wrap("modem")

modem.open(item_delivery_request_channel)
modem.open(warehouse_manifest_channel)

local warehouse_manifests = {}

local function receive_warehouse_manifests()
    while true do
        local _, _, sender_channel, reply_channel, message = os.pullEvent("modem_message")
        (function()
            if typeof(message) ~= "table" or sender_channel ~= warehouse_manifest_channel then
                return
            end
            local warehouse_location_name = get_location_name_for_channel(sender_channel)
            if not warehouse_manifests[warehouse_location_name] then
                warehouse_manifests[warehouse_location_name] = message
            else
                local manifest = warehouse_manifests[warehouse_location_name]
                for item_name, count in pairs(message) do
                    manifest[item_name] = count
                end
            end
        end)()
    end
end

local function find_best_location_name_for_item_delivery_request(location_name, item_name, count)
    -- TODO: Actually implement this
    return location_names_lookup.town
end

local function send_warehouse_item_delivery_request_and_update_warehouse_manifest(warehouse_location_name, location_name, item_name, count)
    warehouse_manifests[warehouse_location_name][item_name] = warehouse_manifests[warehouse_location_name][item_name] - count

    modem.transmit(get_channel_for_location_name + warehouse_location_name, 0, { location_name, item_name, count })
end

local function receive_item_delivery_requests()
    while true do
        local _, _, sender_channel, reply_channel, message = os.pullEvent("modem_message")
        (function()
            if typeof(message) ~= "table" or sender_channel ~= item_delivery_request_channel then
                return
            end
            local location_str, item_str, count = table.unpack(message)

            if count <= 0 then
                return
            end
            if count % 16 ~= 0 then
                return
            end

            local location_name = location_names_lookup[location_str]
            if location_name == nil then
                return
            end
            local item_name = item_names_lookup[item_str]
            if item_name == nil then
                return
            end

            local warehouse_location_name = find_best_location_name_for_item_delivery_request(location_name, item_name, count)

            send_warehouse_item_delivery_request_and_update_warehouse_manifest(warehouse_location_name, location_name, item_name, count)
        end)()
    end
end

parallel.waitForAll(receive_item_delivery_requests, receive_warehouse_manifests)