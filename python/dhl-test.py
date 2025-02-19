import json
from collections import Counter

"""
Load the json file and count the number of inputs

Returns: 
    Prints the count of inputs
"""
with open("dhl.json", "r", encoding="utf-8") as file:
    data = json.load(file)

count = len(data)
print(f"Number of inputs: {count}")

"""
Finds the largest object and prints it into the console.
With the help of max function we find the object with the highest mass.

Arguments:
    obj: object to check

Returns:
    Prints the object with the highest mass
"""
def get_mass(obj):
    return float(obj["mass"]) if "mass" in obj and obj["mass"] else 0

largest_object = max(data, key=get_mass)

print(f"Largest object: {largest_object['name']}, mass: {largest_object['mass']}")

""" 
Extracts the years from the data to a list.
Finds the most frequent year in the list and prints it to the console.

Arguments:
    years: list of years
    
Returns: 
    Most frequent year, count
"""
years = []
for item in data:
    if "year" in item and item["year"]:
        years.append(item["year"][:4])

year_counts = Counter(years)

most_common_year, count = year_counts.most_common(1)[0]

print(f"Most frequent year: {most_common_year}, count: {count}")