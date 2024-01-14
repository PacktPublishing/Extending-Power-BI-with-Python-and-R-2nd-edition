# %%
import os
import pandas as pd
import matplotlib.pyplot as plt
import pkg_resources

# %%
# Retrieve the number of packages to display per page and the current page number from a dataset.
num_packages = dataset['num_packages'].values[0]
num_page = dataset['num_page'].values[0]

# %%
# Generate a list of installed package distributions as strings.
dists = [str(d) for d in pkg_resources.working_set]
# Sort this list alphabetically in a case-insensitive manner.
dists = sorted(dists, key=str.casefold)

# %%
# Calculate the total number of installed packages.
num_tot_packages = len(dists)
# Calculate the starting index for packages to display on the current page.
start_idx = num_packages * (num_page - 1)
# Calculate the ending index for packages to display on the current page.
end_idx = num_packages * num_page

# Adjust the start and end indices based on the total number of packages.
if (start_idx < num_tot_packages) & (end_idx > num_tot_packages):
    # If the calculated end index exceeds the total, adjust it to the total.
    end_idx = num_tot_packages
elif (start_idx >= num_tot_packages) & (end_idx > num_tot_packages):
    # If both start and end indices exceed the total, adjust them to display the last page of packages.
    start_idx = num_tot_packages - (num_tot_packages % num_packages)
    end_idx = num_tot_packages

# Slice the sorted list of packages to get the ones for the current page.
selected_packages = dists[start_idx:end_idx]


# %%
packages = ""
for i in selected_packages:
    packages += f"{i}\n"

plt.rcParams.update({'font.size': 9})
fig=plt.figure()
ax=fig.add_subplot(1,1,1)
plt.text(.05, .5, packages, #'OK!',
         horizontalalignment='center',
         verticalalignment='center',
         transform = ax.transAxes,
         wrap=False)
plt.axis('off')
plt.show()
