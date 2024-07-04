###############################################################################
# Azure Maps documentation: https://learn.microsoft.com/en-us/azure/azure-maps/
###############################################################################
# Azure Maps API Key to be set up separately for security reasons
###############################################################################
# os.environ['AZURE_MAPS_API_KEY'] = '<your-api-key>'
###############################################################################

from azure.core.credentials import AzureKeyCredential
from azure.maps.search import MapsSearchClient
import dask.dataframe as dd
import os
import time

# Authenticate with a Subscription Key Credential
search_client = MapsSearchClient(
    credential = AzureKeyCredential(AZURE_MAPS_API_KEY)
)

def azure_maps_geocode_via_address(address):
    
    try:
        search_result = search_client.search_address(address)
        results       = search_result.results
        first_result  = results[0]
    
        # Number of resources found
        num_resources = search_result.num_results
            
        if num_resources > 0:
            formattedAddress = first_result.address.freeform_address
            lat              = first_result.position.lat
            lng              = first_result.position.lon
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
        
    return num_resources, formattedAddress, lat, lng


def enrich_with_geocoding(passed_row, col_name):

    address_value = str(passed_row[col_name])
    
    num_resources, address_formatted, address_lat, address_lng = azure_maps_geocode_via_address(address_value) 
    
    passed_row_copy                     = passed_row.copy()
    passed_row_copy['numResources']     = num_resources
    passed_row_copy['formattedAddress'] = address_formatted
    passed_row_copy['latitude']         = address_lat
    passed_row_copy['longitude']        = address_lng
    
    return passed_row_copy


ddf_orig = dd.read_csv(
    r'<your-file-path>/geocoding_test_data.csv',
    encoding = 'latin-1'
    )

ddf = ddf_orig[['full_address','lat_true','lon_true']]
ddf = ddf.repartition(npartitions = os.cpu_count() * 2)

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
        'longitude':        'float64'
        }
    )

tic         = time.perf_counter()
enriched_df = enriched_ddf.compute()
toc         = time.perf_counter()

print(f'{enriched_df.shape[0]} addresses geocoded in {toc - tic:0.4f} seconds')

enriched_df
