package = "solr"
version = "0.1-1"
source = {
   url = "git@github.com:alekmarinov/luasolr.git"
}
description = {
   summary = "Lua to Apache Solr connection module",
   detailed = [[
Provides minimalistic interface to solr enabling posting and quering data records 
]],
   homepage = "https://github.com/alekmarinov/luasolr",
   license = "MIT/X11"
}
dependencies = {
   "lua ~> 5.1",
   "luajson",
   "luasocket"
}
build = {
   type = "builtin",
   modules = {
      solr = "lua/solr.lua"
   }
}
