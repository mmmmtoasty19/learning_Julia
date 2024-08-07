using XLSX
using DataFrames
using Chain
using DataFramesMeta
using Dates
using CairoMakie
using AlgebraOfGraphics

# Load Data
df_raw = DataFrame(XLSX.readtable(joinpath("data", "Tableau_practice_data.xlsx"), "05 - Flu Occurrence FY2013-2016"; infer_eltypes=true))


function format_names(x::String)
x = lowercase(x)
x = replace(x, " " => "_", "+" => "pos", "(" => "", ")" => "", "%" => "pct")
return x
end

#need to convert Month to categroical

df = @chain df_raw begin
  rename(format_names, _)
  @rtransform  :month = Dates.month(:date)  #transform by Row
  @rtransform  :year = Dates.year(:date)  #transform by Row
  @rtransform  :flu_year = ifelse(:month >= 10, :year + 1, :year)
end


fig = Figure(; size = (600,400))
ax = Axis(fig[1,1])
lines!(ax, df.month, df.pct_tests_pos_for_influenza; color = df.flu_year)

plt = data(df) * mapping(:month, :pct_tests_pos_for_influenza; color = :flu_year) * visual(Lines)

draw(plt)

fig