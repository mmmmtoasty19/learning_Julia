using XLSX
using DataFrames
using Chain
using DataFramesMeta
using Dates

# Load Data
df_raw = DataFrame(XLSX.readtable(joinpath("data", "Tableau_practice_data.xlsx"), "05 - Flu Occurrence FY2013-2016"; infer_eltypes=true))


function format_names(x::String)
x = lowercase(x)
x = replace(x, " " => "_", "+" => "pos", "(" => "", ")" => "", "%" => "pct")
return x
end



df = @chain df_raw begin
  rename(format_names, _)
  @rtransform  :month = Dates.month(:date)  #transform by Row
  @rtransform  :year = Dates.year(:date)  #transform by Row
  
end
