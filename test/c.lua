-- Create a table
local fruits = {"apple", "banana", "cherry"}

-- Add an element to the table
table.insert(fruits, "date")

-- Print the elements of the table
for i, fruit in ipairs(fruits) do
  print("Fruit " .. i .. " is " .. fruit)
end
