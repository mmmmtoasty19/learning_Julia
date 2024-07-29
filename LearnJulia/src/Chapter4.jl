using DataFrames

function grades_2020()
  name = ["Sally", "Bob", "Alice", "Hank"]
  grade_2020 = [1, 5, 8.5, 4]
  DataFrame(; name, grade_2020)
end