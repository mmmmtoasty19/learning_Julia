using HTTP
using Gumbo
using Cascadia
using DataFrames

url = "https://juckins.net/amtrak_status/archive/html/history.php?train_num=97&station=&date_start=07%2F01%2F2024&date_end=07%2F31%2F2024&df1=1&df2=1&df3=1&df4=1&df5=1&df6=1&df7=1&sort=schDp&sort_dir=DESC&co=gt&limit_mins=&dfon=1"

resp = HTTP.get(url)

page = parsehtml(String(resp.body))
# println(String(resp.body))
s = sel"tr"
rows = eachmatch(s, page.root)

row_text = String[]

# need to make this a nested for loopS
for i in rows
    text = nodeText(eachmatch(Selector("tr"), i)[1])
    println("$text")
    push!(row_text, text)
end

# this appears to work.  Probably not the best way to do it but it works
orgin_date = []
station = []
sch_dp = []
act_dp = []
comments = []
service_disrupt = []
cancellations = []

for i in rows
    text = eachmatch(Selector("td"), i)
    if !isempty(text) && length(text) > 1
        push!(orgin_date, nodeText(text[1]))
        push!(station, nodeText(text[2]))
        push!(sch_dp, nodeText(text[3]))
        push!(act_dp, nodeText(text[4]))
        push!(comments, nodeText(text[5]))
        push!(service_disrupt, nodeText(text[6]))
        push!(cancellations, nodeText(text[7]))
        
        # for el in text
        #     test = nodeText(el) * ','
        #     println(test)
        # end
    end
end


df = DataFrame(orgin_date = orgin_date)