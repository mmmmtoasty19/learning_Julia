#Chapter 8 

using CSV
using DataFrames
using Plots

puzzlespath = joinpath("data", "puzzles.csv");

puzzles = CSV.read(puzzlespath, DataFrame);

show(describe(puzzles))# use to show summary stats

# 8.3.4 Quick Histogram

plot([histogram(puzzles[!,col]; label = col) for 
    col in ["Rating", "RatingDeviation", "Popularity", "NbPlays"]]...)