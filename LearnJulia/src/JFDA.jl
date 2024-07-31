#Chapter 8 

using CSV
using DataFrames
using Plots

puzzles = CSV.read("puzzles.csv", DataFrame);

show(describe(puzzles))# use to show summary stats

# 8.3.4 Quick Histogram

