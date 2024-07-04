###############################################################################
# Azure Maps documentation: https://learn.microsoft.com/en-us/azure/azure-maps/
###############################################################################
# Azure Maps API Key to be set up separately for security reasons
###############################################################################
# os.environ['AZURE_MAPS_API_KEY'] = '<your-api-key>'
###############################################################################

import dask
import dask.dataframe as dd
import json
import os
import requests
import time
import urllib

base_url = "https://atlas.microsoft.com/search/address/json"

def azure_maps_geocode_via_address(address):
    
    encoded_address = urllib.parse.quote(address.strip(), safe='')
    
    # trim the string from leading and trailing spaces using strip
    full_url = f"{base_url}?&subscription-key={AZURE_MAPS_API_KEY}&query={encoded_address}"
    
    r = requests.get(full_url)
    
    try:
        data = r.json()
        
        # Number of resources found
        num_resources = data['summary']['numResults']
        
        if num_resources > 0:
            result           = data['results'][0]
            formattedAddress = result['address']['freeformAddress']
            lat              = result['position']['lat']
            lng              = result['position']['lon']
        else:
            formattedAddress = None
            lat              = None
            lng              = None
            
    except Exception as e:
        print(f"Error: {e}")
        num_resources    = 0
        formattedAddress = None
        lat              = None
        lng              = None
    
    text   = data
    status = r.status_code
    url    = r.url
    
    return num_resources, formattedAddress, lat, lng, text, status, url


def enrich_with_geocoding(passed_row, col_name):

    address_value = str(passed_row[col_name])
    
    num_resources, address_formatted, address_lat, address_lng, text, status, url = azure_maps_geocode_via_address(address_value)
    
    passed_row_copy                     = passed_row.copy()
    passed_row_copy['numResources']     = num_resources
    passed_row_copy['formattedAddress'] = address_formatted
    passed_row_copy['latitude']         = address_lat
    passed_row_copy['longitude']        = address_lng
    passed_row_copy['text']             = text
    passed_row_copy['status']           = status
    passed_row_copy['url']              = url
    
    return passed_row_copy


ddf_orig = dd.read_csv(
    r'<your-file-path/geocoding_test_data.csv',
    encoding = 'latin-1'
    )

ddf = ddf_orig[['full_address','lat_true','lon_true']]
ddf.npartitions

ddf = ddf.repartition(npartitions=os.cpu_count())
ddf.npartitions

enriched_ddf = ddf.apply(
    enrich_with_geocoding,
    axis     = 1,
    col_name = 'full_address',
    meta     = {
        'full_address':     'string',
        'lat_true':         'float64',
        'lon_true':         'float64',
        'numResources':     'int32',
        'formattedAddress': 'string',
        'latitude':         'float64',
        'longitude':        'float64',
        'text':             'string',
        'status':           'string',
        'url':              'string'
        }
    )

tic         = time.perf_counter()
enriched_df = enriched_ddf.compute(num_workers=os.cpu_count())
toc         = time.perf_counter()

print(f'{enriched_df.shape[0]} addresses geocoded in {toc - tic:0.4f} seconds')

enriched_df
