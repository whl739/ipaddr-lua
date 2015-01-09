
local bit = require('bit')
local bnot, band, bor = bit.bnot, bit.band, bit.bor
local bxor, lshift, rshift = bit.bxor, bit.lshift, bit.rshift
local insert = table.insert
local tostring = tostring
local tonumber = tonumber
local concat = table.concat
local setmetatable = setmetatable
local ipairs = ipairs
local unpack = unpack
local type = type

module(...)

_VERSION = '0.01'

local mt = { __index = _M }

local function map(func, ...)
    local result = {}
    for _, v in ipairs{...} do insert(result, func(v)) end
    return unpack(result)
end

local function rangetest(min, max)
    return function(v)
        return type(v)=='number' and min<=v and v<=max
    end
end

local function allok(...)
    for _, v in ipairs{...} do
        if not v then
            return false
        end
    end
    return true
end

local ipv4_length = 32
local all_ones = lshift(2, ipv4_length - 1) - 1

function new(self, ...)
    local t = {}
    setmetatable(t, mt)
    local ip1, ip2, ip3, ip4, mask = map(tonumber, ...)
    if not ip1 then
        return
    end
    mask = mask or ipv4_length
    if not allok(
        rangetest(0, ipv4_length)(mask),
        map(rangetest(0, 255), ip1, ip2, ip3, ip4)
        ) then
        return
    end
    t.netmask = bxor(all_ones, rshift(all_ones, mask))
    t.hostmask = bxor(t.netmask, all_ones)
    local octets = {ip1, ip2, ip3, ip4}
    local packed_ip = 0
    for i = 1, #octets do
        packed_ip = bor(lshift(packed_ip, 8), octets[i])
    end
    t.network = packed_ip
    t.broadcast = bor(t.network, t.hostmask)
    return t
end

function contains(self, other)
    return self.network <= other.network and other.network <= self.broadcast
end

function compare(self, other)
    if self.network ~= other.network then
        return self.network < other.network
    end
    return self.netmask < other.netmask
end

function str(self)
    local ip_int = self.network
    local octets = {}
    for i = 1, 4 do
        insert(octets, 1, tostring(band(ip_int, 0xFF)))
        ip_int = rshift(ip_int, 8)
    end
    return concat(octets, '.')
end

mt.__tostring = str
mt.__lt = compare

