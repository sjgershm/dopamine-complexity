dopamine-complexity
====

Code and data for "Policy complexity suppresses dopamine responses" by Gershman and Lak.

Questions? Contact Sam Gershman (gershman@fas.harvard.edu).

When you start Matlab, add the 'util' folder to the path.

To load the data, call ```tbl = readtable('Lak20_dopamine_data.csv')```. If you want to reproduce or modify the preprocessing pipeline, first obtain the raw data from [here](https://figshare.com/articles/dataset/VTA_DA_Vis2AFC/24298336?file=42649654), load the file and then call ```tbl = extract_trial_data_Lak20(BehPhotoM)```, which returns the processeed data in tabular format and also saves it as a csv file ('Lak20_dopamine_data.csv').

To reproduce the main behavioral results figure, call ```plot_figures('behavioral_results',tbl)```.

To reproduce the main neural results figure, call ```plot_figures('neural_results',tbl)```.

