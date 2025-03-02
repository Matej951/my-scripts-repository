import json
import requests
from collections import Counter
import logging
import datetime

"""
Sets up logging.
"""

logging.basicConfig(
    filename=f"dhl_analysis_{datetime.datetime.now().strftime('%d%m%Y')}.log",
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

"""
Sets the URL of the data source.
"""

DATA_URL = "http://localhost:90/api/files/download/dhl.json"

"""
Tries to download the latest data from the API and saves them as json.
If the download fails, it logs the error into a log file.
"""

def fetch_latest_data():
    try:
        logging.info("Downloading latest data...")
        response = requests.get(DATA_URL, timeout=30)
        response.raise_for_status()
        data = response.json()
        logging.info(f"Data successfully downloaded")

        return data

    except Exception as e:
        logging.error(f"Error while downloading data: {e}")

"""
Saves the result of function fetch_latest_data() into a variable.
"""

data=fetch_latest_data()

"""
Counts the number of inputs and prints it into the console.

Arguments:
    data: data to count

Returns:
    Prints the number of inputs
"""

count = len(data)
print(f"Number of inputs: {count}")

"""
Finds the largest object and prints it into the console.
With the help of max function we find the object with the highest mass.

Arguments:
    obj: object to check

Returns:
    Prints the object with the highest mass
    
### old solution
def get_mass(obj):
    return float(obj["mass"]) if "mass" in obj and obj["mass"] else 0

largest_object = max(data, key=get_mass)

### new solution
Uses anonymous lambda function that accepts obj as an argument and returns float.
We use the get() method to get the value of the "mass" key, or we return 0 if it doesn't exist.
"""

largest_object = max(data, key=lambda obj: float(obj.get("mass", 0) or 0))
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

"""
Returns a list of most common years () and select the position from the list to return []
"""
most_common_year, count = year_counts.most_common(1)[0]
print(f"Most frequent year: {most_common_year}, count: {count}")

"""
Logs the completion of the analysis.
"""
logging.info(f"Analysis completed at {datetime.datetime.now().strftime('%d.%m.%Y %H:%M:%S')}")