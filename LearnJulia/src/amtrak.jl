using HTTP
using Gumbo
using Cascadia

url = "https://juckins.net/amtrak_status/archive/html/history.php?train_num=97&station=&date_start=07%2F01%2F2024&date_end=07%2F31%2F2024&df1=1&df2=1&df3=1&df4=1&df5=1&df6=1&df7=1&sort=schDp&sort_dir=DESC&co=gt&limit_mins=&dfon=1"

resp = HTTP.get(url)

page = parsehtml(String(resp.body))
# println(String(resp.body))
sel = Selector("table")
s = sel"tr"
eachmatch(sel, page.root)
rows = eachmatch(s, page.root)


# need to make this a nested for loopS
for i in rows
    text = nodeText(eachmatch(Selector("tr"), i)[1])
    println("$text")
end

for i in rows
    e = eachmatch(Selector("tr"), i)
    for x in e
    text = nodeText(eachmatch(Selector("td"),x)[1])
    println("$text")
    end
end