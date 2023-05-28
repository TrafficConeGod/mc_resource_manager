-- Reserved channel range is 1, 2, and 65408-65535

return { 1, 2, function(location_name)
    return 65408 + location_name
end, function(channel)
    return location_name - 65408
end }