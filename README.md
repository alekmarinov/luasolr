# luasolr
Lua to Apache Solr connection module

Provides minimalistic interface to solr enabling posting and quering data records 

## Install with LuaRocks
luarocks install solr

## Example

```lua
solr = require "solr"
slr = solr.new("gettingstarted")
slr:post{id=1, text="solr rocks"}
docs = slr:query{q="text:solr"}.response.docs
print(docs[1].id) -- 1
slr:delete(1)
```
