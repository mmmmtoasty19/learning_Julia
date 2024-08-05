using DataFrames
using CSV
using Dates
using CategoricalArrays
using DataFramesMeta

# Julia for Data Sciences makes use of functions to keep variable scooping under control

function grades_2020()
  name = ["Sally", "Bob", "Alice", "Hank"]
  grade_2020 = [1, 5, 8.5, 4]
  DataFrame(; name, grade_2020)
end

function write_grades()
  path = joinpath("data", "grades.csv")
  CSV.write(path, grades_2020())
end

# Chapter 4.3

filter(:name => ==("Alice"), grades_2020())

function complex_filter(name, grade)::Bool
  name = startswith(name, "A") || startswith(name, "B")
  grade = 6 < grade
  name && grade
end

filter([:name, :grade_2020] => complex_filter, grades_2020())

function salaries()
  names = ["John", "Hank", "Karen", "Zed"]
  salary = [1_900, 2_800, 2_800, missing]
  DataFrame(; names, salary)
end

subset(salaries(), :salary => ByRow(>(2_000)); skipmissing = true)

# Chapter 4.4
function responses()
  id = [1, 2]
  q1 = [28, 61]
  q2 = [:us, :fr]
  q3 = ["F", "B"]
  q4 = ["B", "C"]
  q5 = ["A", "E"]
  DataFrame(; id, q1, q2, q3, q4, q5)
end

renames = (1 => "particiapant", :q1 =>"age", :q2 => "nationality")
select(responses(), renames...)

# Chapter 4.5
function wrong_types()
  id = 1:4
  date = ["28-01-2018", "03-04-2019", "01-08-2018", "22-11-2020"]
  age = ["adolescent", "adult", "infant", "adult"]
  DataFrame(; id, date, age)
end

# Trying out DataFramesMeta
df = wrong_types()
ages_levels = ["infant", "adolescent", "adult"]
strings2dates(dates::Vector) = Date.(dates, dateformat"dd-mm-yyyy")


@transform df begin
  :date = strings2dates(:date)
  :age = categorical(:age; levels = ages_levels, ordered = true)
end
