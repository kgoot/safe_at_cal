import pandas as pd
from sodapy import Socrata
from geopy.geocoders import Nominatim
import json
from firebase import firebase
import requests


firebase = firebase.FirebaseApplication('https://walkme-29.firebaseio.com', None)
client = Socrata("data.cityofberkeley.info", "EHyIXZQfhWAoEgTV0xxgWtKu0", username="kgoot@berkeley.edu", password="Cokacola123")
results = client.get("s24d-wsnp", limit=10000)

filtered = {}
counter = 1
geolocator = Nominatim()
for result in results:
	if "block_location" in result.keys():
		try:
			result["lat"] = result["block_location"]["coordinates"][1]
			result["long"] = result["block_location"]["coordinates"][0]
			result["latlong"] = list((result["lat"], result["long"]))
			result["address"] = geolocator.reverse(result["latlong"]).address
			result["zip"] = result["address"].split(r', ')[-2]
			firebase.post('/crimes/{0}'.format(count), data=result)
			filtered[counter] = result
			counter += 1
		except:
			pass

# firebase.post('/crimes', data=filtered)
print(len(filtered))

