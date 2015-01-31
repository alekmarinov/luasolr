require "solr"

slr = solr.new("collection1")

data = {}
for i = 1, 5 do
	table.insert(data, {id = i, title = "sample title "..i})
end
assert(slr:post(data))

count = slr:query().response.numFound
all = slr:query{ q = "*", rows = count}
print("all: "..count.." results found\n"..string.rep("-", 15))

for _, doc in ipairs(all.response.docs) do
	print(doc.id, doc.title[1])
end

-- create it unique
slr:post{{id = 9, title = "find me"}}

-- find it
result = slr:query("find")
assert(result.response.numFound == 1)

-- delete it
slr:delete(9)
result = slr:query("find")
assert(result.response.numFound == 0, result.response.numFound)
