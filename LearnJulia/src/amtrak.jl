using HTTP
using Gumbo
using Cascadia
using DataFrames
using DataFramesMeta
using Dates

url = "https://juckins.net/amtrak_status/archive/html/history.php?train_num=97&station=&date_start=07%2F01%2F2024&date_end=07%2F31%2F2024&df1=1&df2=1&df3=1&df4=1&df5=1&df6=1&df7=1&sort=schDp&sort_dir=DESC&co=gt&limit_mins=&dfon=1"

resp = HTTP.get(url)

page = parsehtml(String(resp.body))
# println(String(resp.body))
s = sel"tr"
rows = eachmatch(s, page.root)

# create empty DataFrame and then populate it with the table from website
df = DataFrame(orgin_date = [], station = [], sch_dp = [], act_dp = String[], comments = [], s_disrupt = [], cancellations = [])

for i in rows
    text = eachmatch(Selector("td"), i)
    row_data = []
    if !isempty(text) && length(text) > 1
        for item in text
            push!(row_data, nodeText(item))
            # println("$item,")
        end
    push!(df, row_data)
    end
end


mod_df = @chain df begin
    @rsubset :act_dp != ""
    @rtransform _ begin
        :act_dp = Time(:act_dp, dateformat"HH:MMp")
        :orgin_date = Date(replace(:orgin_date,  r" \(.*\)" => ""), dateformat"mm/dd/YYYY")
        :sch_dp = DateTime(replace(:sch_dp,  r" \(.*\)" => ""), dateformat"mm/dd/YYYY HH:MM p")
    end
end

