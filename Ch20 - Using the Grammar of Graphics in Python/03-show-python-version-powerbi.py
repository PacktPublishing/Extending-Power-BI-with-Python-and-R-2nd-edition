# %%
import sys
import matplotlib.pyplot as plt

# %%
ver = sys.version_info
label = f'{ver.major}.{ver.minor}.{ver.micro}'

plt.rcParams.update({'font.size': 22})
fig=plt.figure()
ax=fig.add_subplot(1,1,1)
plt.text(0, 1, label,
         horizontalalignment='center',
         verticalalignment='center',
         transform = ax.transAxes,
         wrap=False)
plt.axis('off')
plt.show()

# %%
