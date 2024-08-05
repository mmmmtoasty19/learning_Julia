using XLSX
using DataFrames
using Chain
using Cleaner
# Load Data

df = DataFrame(XLSX.readtable(joinpath("data", "Tableau_practice_data.xlsx"), "05 - Flu Occurrence FY2013-2016"))




@chain df begin
  polish_names
end