## Project Developing Data Products
###1.Introduction
This app shows the historical air quality index (AQI) data of several cities in China.
Other than AQI data,  the app also shows the concentration of multiple pollutants. They are:
**PM2.5**  
**PM10**  
**SO<sub>2</sub>**  
**CO**  
**NO<sub>2</sub>**  
**O<sub>3</sub>**

###2. App UI components
The app has **six** input components and **three** output components.
The input components are:

Two **selectinput** inputs (*which city*) which enables users to choose a primary city and the other city to compare with.

One **actionbutton** input (*Compare to*) that enable/disable the comparison option

Two **radionbuttons** inputs that allow users to choose the average option (*Average choice*) for data and which data component to show (*AQI component*)

One **datainput** input (*Date:*)

The output component are:

**dataoutput** shows the AQI component data of the chosen city in the chosen date. (format: Baoji: 145) 

**tabledataoutput** shows all the AQI components data of the chosen city in the chosen date. 

**plotoutput** shows the averaged AQI components data by graph.

If the **Compare to** button is activated, both the data for both cities will be shown.

###3.Reference

All the data are taken from the website:
https://www.aqistudy.cn/historydata/index.php

 

