# THIS SCRIPT IS SUPPOSED TO RUN IN A JUPYTER NOTEBOOK (WE USED VS CODE)

# %%
import os
import requests
import urllib
import json
import pandas as pd
import time


# %%
def bing_geocode_via_address(address):
    # trim the string from leading and trailing spaces using strip
    full_url = f"{base_url}query={urllib.parse.quote(address.strip(), safe='')}?key={AUTH_KEY}"
    
    r = requests.get(full_url)
    
    try:
        data = r.json()
        
        # number of resources found, used as index to get the
        # latest resource
        num_resources = data['resourceSets'][0]['estimatedTotal']
        formattedAddress = data['resourceSets'][0]['resources'][num_resources-1]['address']['formattedAddress']
        lat = data['resourceSets'][0]['resources'][num_resources-1]['point']['coordinates'][0]
        lng = data['resourceSets'][0]['resources'][num_resources-1]['point']['coordinates'][1]
    except:
        num_resources = 0
        formattedAddress = None
        lat = None
        lng = None
    
    text = r.text
    status = r.reason
    url = r.url
    
    return num_resources, formattedAddress, lat, lng, text, status, url
    
def enrich_with_geocoding(passed_row, col_name):
    address_value = str(passed_row[col_name])
    
    num_resources, address_formatted, address_lat, address_lng, text, status, url = bing_geocode_via_address(address_value)
    
    passed_row_copy = passed_row.copy()

    passed_row_copy['numResources'] = num_resources
    passed_row_copy['formattedAddress'] = address_formatted
    passed_row_copy['latitude'] = address_lat
    passed_row_copy['longitude'] = address_lng
    passed_row_copy['text'] = text
    passed_row_copy['status'] = status
    passed_row_copy['url'] = url
    
    return passed_row_copy


# %%
####################################################################################################
# To be set up separately for security reasons
####################################################################################################
os.environ['BINGMAPS_API_KEY'] = '<your-api-key>'
####################################################################################################

# %%
base_url= "http://dev.virtualearth.net/REST/v1/Locations/"
AUTH_KEY = os.environ.get('BINGMAPS_API_KEY')

# %%
df_orig = pd.read_csv(r'D:\<your-path>\Ch11 - Calling External APIs To Enrich Your Data\geocoding_test_data.csv',
                      encoding='latin-1')

df = df_orig[['full_address','lat_true','lon_true']]
df

# %%
tic = time.perf_counter()

enriched_df = df.apply(enrich_with_geocoding, col_name='full_address', axis=1)

toc = time.perf_counter()

print(f'{df.shape[0]} addresses geocoded in {toc - tic:0.4f} seconds')


# %%
enriched_df

# %%
