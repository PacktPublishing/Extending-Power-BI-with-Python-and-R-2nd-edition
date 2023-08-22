# %%
import os
import pandas as pd
import matplotlib.pyplot as plt
import pkg_resources

# %%
# # Uncomment this chunk if you need to debug all the code
# def cartesian_product(src_dict):
#     index = pd.MultiIndex.from_product(src_dict.values(), names=src_dict.keys())
#     return pd.DataFrame(index=index).reset_index()

# tot_num_pages = 20
# dataset = cartesian_product({   'num_packages': [10, 20, 30],
#                                 'num_page': [i for i in range(1, tot_num_pages+1)]})
# dataset


# row_idx = 1

# dataset = dataset.iloc[[row_idx]]

# %%
num_packages = dataset['num_packages'].values[0]
num_page = dataset['num_page'].values[0]

print(f"num_packages = {num_packages}  |  num_page = {num_page}")

# %%
dists = [str(d) for d in pkg_resources.working_set]
dists = sorted(dists, key=str.casefold)

dists

# %%
num_tot_packages = len(dists)
start_idx = num_packages * (num_page - 1)
end_idx = num_packages * num_page

if (start_idx < num_tot_packages) & (end_idx > num_tot_packages):
    end_idx = num_tot_packages
elif (start_idx >= num_tot_packages) & (end_idx > num_tot_packages):
    start_idx = num_tot_packages - (num_tot_packages % num_packages)
    end_idx = num_tot_packages

selected_packages = dists[start_idx:end_idx]

# %%


packages = ""
for i in selected_packages:
    packages += f"{i}  |  "


fig=plt.figure()
ax=fig.add_subplot(1,1,1)
plt.text(0.05, 0.95, packages, #'OK!',
         horizontalalignment='left',
         verticalalignment='center',
         transform = ax.transAxes,
         wrap=True)
plt.axis('off')
plt.show()

    
# %%
