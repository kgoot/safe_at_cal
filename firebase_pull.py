# updating firebase database with current crime data

#install requests in terminal
# pipenv install requests
# $ git clone git://github.com/requests/requests.git
# cd requests
# pip install

import requests
from firebase import firebase

r2 = requests.get('https://data.cityofberkeley.info/resource/s24d-wsnp.json')
r2.json()

firebase = firebase.FirebaseApplication('https://walkme-29.firebaseio.com', None)
i=0
while i < len(r2.json()):
	new_crime = r2.json()[i]
	result = firebase.post('/crimes', data = new_crime)
	print(result)
	i += 1


# from berkeley API
#!/usr/bin/env python

# make sure to install these packages before running:
# pip install pandas
# pip install sodapy

#import pandas as pd
#from sodapy import Socrata

# Unauthenticated client only works with public data sets. Note 'None'
# in place of application token, and no username or password:
#client = Socrata("data.cityofberkeley.info", None)

# Example authenticated client (needed for non-public datasets):
# client = Socrata(data.cityofberkeley.info,
#    			  KwJUOlLY9BQI57A6ddE8UKUQ9,
#                 userame="lilygeerts@gmail.com",
#                 password="WalkMeb3rk3l3y")

# First 2000 results, returned as JSON from API / converted to # Python list of
# dictionaries by sodapy.
#results = client.get("s24d-wsnp", limit=2000)

# Convert to pandas DataFrame
#results_df = pd.DataFrame.from_records(result_list)