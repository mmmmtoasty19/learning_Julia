#Chapter 8 

using CSV
using DataFrames
using Plots
using SQLite

puzzlespath = joinpath("data", "puzzles.csv");

puzzles = CSV.read(puzzlespath, DataFrame);

show(describe(puzzles))# use to show summary stats

# 8.3.4 Quick Histogram

plot([histogram(puzzles[!,col]; label = col) for 
    col in ["Rating", "RatingDeviation", "Popularity", "NbPlays"]]...)


# 8.4.2 SQLITE
db = SQLite.DB(joinpath("data", "puzzles.db"));
SQLite.load!(puzzles, db, "puzzles") # add puzzles to Database into a table named Puzzles

query = DBInterface.execute(db, "SELECT * FROM puzzles")

puzzles_db = DataFrame(query);

close(db)


# Chapter 9

using Statistics

plays_lo = median(puzzles.NbPlays);
rating_lo = 1500;
rating_hi = quantile(puzzles.Rating, 0.99);

row_selector = (puzzles.NbPlays .> plays_lo) .&&
  (rating_lo .< puzzles.Rating .< rating_hi);

good = puzzles[row_selector, ["Rating", "Popularity"]]

plot(histogram(good.Rating; label = "Rating"), histogram(good.Popularity; label = "Popularity"))

# Exercise 9.1

using StatsBase

nb_100 = copy(puzzles[(puzzles.Popularity .== 100) , "NbPlays"])
nbnot100 = copy(puzzles[(puzzles.Popularity .== -100) , "NbPlays"])
summarystats(nb_100)
summarystats(nbnot100)

