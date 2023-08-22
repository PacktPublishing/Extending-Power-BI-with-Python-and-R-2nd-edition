# %%
import urllib.request
import json
import os
import ssl
import numpy as np
import pandas as pd


# %%
def allowSelfSignedHttps(allowed):
    # bypass the server certificate verification on client side
    if allowed and not os.environ.get('PYTHONHTTPSVERIFY', '') and getattr(ssl, '_create_unverified_context', None):
        ssl._create_default_https_context = ssl._create_unverified_context


def ExtractElementOfSublist(lst, idx):
    return [item[idx] for item in lst]


def consumeAzureMLEndpoint(url, api_key, obs_df, threshold=0.5):
    # Request data goes here
    json_records_str = obs_df.to_json(orient='records')
    data_str = f'''{{
    "Inputs": {{
        "data":{json_records_str}
    }},
    "GlobalParameters": {{
        "method": "predict_proba"
    }}
    }}
    '''
    data = json.loads(data_str)

    # The azureml-model-deployment header will force the request to go to a specific deployment.
    # Remove the 'azureml-model-deployment' header to have the request observe the endpoint traffic rules
    headers = {'Content-Type':'application/json', 'Authorization':('Bearer '+ api_key), 'azureml-model-deployment': 'titanic-model-01' }

    body = str.encode(json.dumps(data))

    req = urllib.request.Request(url, body, headers)

    try:
        response = urllib.request.urlopen(req)
        j = json.loads(response.read())
        
        res_lst = ExtractElementOfSublist(j['Results'], idx=1)
        
        result = pd.DataFrame(res_lst, columns = ['predicted_proba'], dtype = float)
        result['predicted_label'] = np.where( result['predicted_proba'] >= threshold, 1, 0)

    except urllib.error.HTTPError as error:
        print("The request failed with status code: " + str(error.code))

        # Print the headers - they include the requert ID and the timestamp, which are useful for debugging the failure
        print(error.info())
        print(json.loads(error.read().decode("utf8", 'ignore')))

        result = None
    
    return result


# %%
# #############################################################################################
# # Set up environment variables separately for security reasons. Uncomment to use this code.
# #############################################################################################
# os.environ['ENDPOINT_URL'] = '<your-endpoint-url>'
# os.environ['ENDPOINT_API_KEY'] = '<your-api-key>'
# #############################################################################################

# %%
allowSelfSignedHttps(True) # this line is needed if you use self-signed certificate in your scoring service.

# %%
url = os.environ.get('ENDPOINT_URL')
api_key = os.environ.get('ENDPOINT_API_KEY')

if not api_key or (api_key == '<your-endpoint-key>'):
    raise Exception("A key should be provided to invoke the endpoint")

# %%
# # Uncomment this code if you're not using it in Power BI
# # in order to load the imputed test dataset
# dataset = pd.read_csv(r'C:\<your-path>\Ch17 - Using Machine Learning Without Premium or Embedded Capacity\titanic-test.csv',
#                       index_col=False)

# %%
obs = dataset.drop('Survived',axis=1)

# %%
predictions = consumeAzureMLEndpoint(url, api_key, obs, 0.5)
predictions

# %%
scored_df = pd.concat([dataset, predictions],axis=1)
scored_df

# %%
