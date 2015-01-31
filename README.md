# luasolr
Lua to Apache Solr connection module

Provides minimalistic interface to solr enabling posting and quering data records 

## install
luarocks install solr

## example

    require "solr"
    slr = solr.new("collection1")
    slr:post{id=1, text="solr rocks"}
    docs = slr:query{q="solr"}.response.docs
    print(docs[1].id) -- 1
    slr:delete(1)
