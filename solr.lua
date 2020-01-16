-----------------------------------------------------------------------
--                                                                   --
-- Filename:    solr.lua                                             --
-- Description: Lua to Apache Solr connection module                 --
--                                                                   --
-----------------------------------------------------------------------

local http   = require "socket.http"
local url    = require "socket.url"
local json   = require "json"
local ltn12  = require "ltn12"

local _M = {
    _VERSION = "0.2.1",
    _DESCRIPTION = "Lua to Apache Solr connection module"
}

local function createurl(self, command, query)
    return url.build{
        scheme = "http",
        host = self.host,
        port = self.port,
        path = self.base..self.collection..command,
        query = query
    }
end

function _M:request(command, query, data)
    local result = {}

    -- creates http request object
    local req = {
        url     = createurl(self, command, query),
        sink    = ltn12.sink.table(result),
        headers = {
            ["Connection"] = "close"
        }
    }

    if data then
        -- prepares for post
        req.method = "POST"
        req.headers["Content-Type"] = "application/json; charset=utf-8"
        if type(data) == "table" then
            data = json.encode(data)
        end
        if type(data) == "function" then
            req.source = data
        elseif type(data) == "string" then
            req.source = ltn12.source.string(data)
            req.headers["Content-Length"] = string.len(data)
        else
            assert(nil, "expected data argument function or string, got "..type(data))
        end
    end

    -- sends request
    local _, code = http.request(req)
    return json.decode(table.concat(result)), code
end

-- query data
function _M:query(query)
    -- request json response
    local params = { "wt=json" }

    -- format query params
    if type(query) == "table" then
        for name, value in pairs(query) do
            if type(value) == "table" then
                -- multiple query parameters
                for _, v in ipairs(value) do
                    table.insert(params, name.."="..url.escape(v))
                end
            else
                value = tostring(value)
                table.insert(params, name.."="..url.escape(value))
            end
        end
    elseif type(query) == "string" then
        table.insert(params, "q="..url.escape(query))
    else
        assert(type(query) == "nil", "unexpected query type "..type(query))
        table.insert(params, "q=*")
    end

    -- perform query request
    return self:request("/select", table.concat(params, "&"))
end

-- post data
function _M:post(data)
    -- request json response and auto commit
    local queryparams = { "wt=json", "commit=true" }

    if #data == 0 then
        data = {data}
    end

    -- perform query request
    return self:request("/update", table.concat(queryparams, "&"), data)
end

-- delete by id
function _M:delete(id)
    return self:post(json.encode{ delete = { id = id }})
end

-- creates new object to bind solr
function _M.new(options)
    if type(options) == "string" then
        options = {collection = options}
    else
        assert(type(options) == "table", "string or table argument expected, got "..type(options))
        assert(type(options.collection) == "string", "options.collection string expected, got "..type(options.collection))
    end

    options.host  = options.host or "localhost"
    options.port  = options.port or 8983
    options.base  = options.base or "solr"

    string.gsub(options.base, "^/", "")
    string.gsub(options.base, "/$", "")
    options.base = "/"..options.base.."/"
    return setmetatable(options, {__index = _M})
end

return _M
