using DataFrames
using CSV

# Julid for Data Sciences makes use of functions to keep variable scooping under control

function grades_2020()
  name = ["Sally", "Bob", "Alice", "Hank"]
  grade_2020 = [1, 5, 8.5, 4]
  DataFrame(; name, grade_2020)
end

function write_grades()
  path = joinpath("data", "grades.csv")
  CSV.write(path, grades_2020())
end


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