using HTTP
using Gumbo
using Cascadia
using DataFrames
using DataFramesMeta
using Dates
using Statistics
using AlgebraOfGraphics
using CairoMakie
using CategoricalArrays


url = "https://juckins.net/amtrak_status/archive/html/history.php?train_num=97%2C98&station=&date_start=07%2F01%2F2024&date_end=07%2F31%2F2024"

resp = HTTP.get(url)

page = parsehtml(String(resp.body))
# println(String(resp.body))
s = sel"tr"
rows = eachmatch(s, page.root)

# create empty DataFrame and then populate it with the table from website
df = DataFrame(train = String[], orgin_date = [], station = String[], sch_dp = [], act_dp = String[], comments = [], s_disrupt = [], cancellations = [])

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

#This causes an issue with two stations becauses trains often arrive one day and leave the next
# mod_df = @chain df begin
#     @rsubset :act_dp != "" && :s_disrupt != "SD"
#     @select Not(:comments, :s_disrupt, :cancellations)
#     @rtransform _ begin
#         :act_dp = Time(:act_dp, dateformat"HH:MMp")
#         :orgin_date = Date(replace(:orgin_date,  r" \(.*\)" => ""), dateformat"mm/dd/YYYY")
#         :sch_dp = DateTime(replace(:sch_dp,  r" \(.*\)" => ""), dateformat"mm/dd/YYYY HH:MM p")
#     end
#     # @rtransform  :delay = canonicalize(Dates.CompoundPeriod(:act_dp - Time(:sch_dp)))
#     # @rtransform  :delay = canonicalize(:act_dp - Time(:sch_dp))
#     @rtransform  :delay = Dates.value(Minute(:act_dp - Time(:sch_dp)))
# end


mod_df = @chain df begin
    @rsubset :act_dp != "" && :s_disrupt != "SD"
    @select :train :station :comments
    #can't perform match if there is nothing there
    @rtransform :delay =  if occursin(r"Dp:", :comments) match(r"Dp:.*", :comments).match else "" end 
    @rtransform :min = if occursin(r"min", :delay) match(r"[0-9]* min", :delay).match |> 
        x -> parse(Int,match(r"[0-9]*", x).match) else Int(0) end
    @rtransform :hour = if occursin(r"hr", :delay) match(r"[1-9]* hr", :delay).match |> 
        x -> parse(Int,match(r"[1-9]*", x).match) |> x -> x*60  else Int(0) end
    @rtransform :total_delay_mins = :min + :hour |> x -> ifelse(occursin(r"late", :delay), x, x *-1)
    @transform :station = categorical(:station)
end


gd = @chain mod_df begin
    @by _ [:train,:station] begin
        :mean = Float32[Statistics.mean(:total_delay_mins)]
        :median = Statistics.median(:total_delay_mins)
        :max = maximum(:total_delay_mins)
        :min = minimum(:total_delay_mins)
    end  
    @orderby :station :train
    @groupby :station
    @transform :diff = [missing; diff(:mean)]
    @rtransform :station_code = levelcode(:station)
end

# plot(bar(gd.station, gd.mean), xticks = (1:length(gd.station), gd.station), xrotation = 90, legend = false, title = "Mean Delay by Station", xlabel = "Station", ylabel = "Delay (mins)")

axis = (width = 750, height = 750,  title = "Mean Delay by Station", xlabel = "Station", ylabel = "Delay (mins)",xticklabelrotation = 45)

mean_delay = data(gd) * mapping(:station, :mean, color = :train => "Train", dodge = :train) * visual(BarPlot)

draw(mean_delay; axis = axis)

CairoMakie.barplot(gd.station_code, gd.mean)