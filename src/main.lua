local location_names_lookup, item_names_lookup = table.unpack(require("src/lookup")[1])

local function main(location_str, item_str, count)
    if location_str == nil or item_str == nil or count == nil then
        error("Usage: mrm <location> <item> <count>")
    end
    location_str = location_str:lower()
    item_str = item_str:lower()
    count = tonumber(count)
    if count == nil then
        error("Count must be a number")
    end
    if count <= 0 then
        error("Count must be greater than zero")
    end

    local location_name = location_names_lookup[location_str]
    local item_name = item_names_lookup[item_str]
    if location_name == nil then
        error("Invalid location name")
    end
    if item_name == nil then
        error("Invalid item name")
    end
    
    print("Dispatching train to", location_str, "for", count, "of", item_str)
end

return main