# ipaddr-lua

lua  IP address manipulation library

## usage

    local ipaddr = require('ipaddr')
    local insert = table.insert
    local sort = table.sort

    local function compare_networks(a, b)
        return a:compare(b)
    end

    local ipranges = {}

    lines = {
        "1.0.0.0/24",
        "1.0.4.0/22",
    }
    for i=1, #lines do
        local range = ipaddr:new(lines[i]:match('^%s*(%d+)%.(%d+)%.(%d+)%.(%d+)/(%d+)%s*$'))
        if range then
            insert(ipranges, range)
        end
    end
    sort(ipranges, compare_networks)

    local test = '1.0.0.1'
    ip = ipaddr:new(test:match('^%s*(%d+)%.(%d+)%.(%d+)%.(%d+)'))
    print(ip.netmask, ip.network, ip.broadcast, ip.str(ip))
    for _, r in ipairs(ipranges) do
        local ret = compare_networks(r, ip)
        if not ret and r.contains(r, ip) then
            print(r.network, ip.network, r.broadcast)
        else
            print(false)
        end
    end


