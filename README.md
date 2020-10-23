# Soohyun_Portfolio
Soohyun Hwangbo's Compilation of Projects &amp; Works

## About Me

*In the process of revamping my portfolio

I am a rising senior at New York University Abu Dhabi, currently on leave of absence. I study Economics and Sociology with a minor in Mathematics, and I'm primarily interested in how insights can be drawn from data in computational social science to drive business and policy decisions. Sounds pretty vague, but as an undergrad who recently got into this direction I hope to gain more exposure to different problems in real-life, and how they can be solved. I still have a long, long way to go, but wanted to devote this space to organize my past work and actually make use of Github. 

I have mainly worked with R in my projects, but I am picking up SQL and Python on my own through online tutorials. Aside from data, tech and studies I also like to write and travel.

## [California Employment Discrimination (2020 Summer)](https://github.com/sh4733/Soohyun_Portfolio/tree/main/Cali_Employment_Discrimination)

Language Used: R (tidyverse, ggmap, sf, tmap)

I worked as a summer research fellow for a sociology project that examined the impact of socioeconomic factors and firm-level characteristics on employment discrimination filings in California. Some of the main tasks conducted are:

1) Address data cleaning & geocoding: I cleaned and processed the textual data of addresses in the complaints file to identify geographic coordinates of the companies, and visualized the information by census-tract level. 

#### Interactive Map of Number of Complaints by Census Tract Level

![alt text](https://github.com/sh4733/Soohyun_Portfolio/blob/main/images/cali_ctract_map.png)

2) Socioeconomic variables dataset building: I built a data set of relevant socioeconomic variables by census-tract level from Social Explorer. 

3) Linking company characteristics database with the complaints data set: We obtained a data set containing information of all companies from 2015 - 2018, which adds up to around 1.6 million companies every year. By implementing near-duplicate matching conditioned on company name and address, I applied fuzzy matching algorithm on to filter for apporximately similar companies, for merging into a single data set.

## Twitter Sentiment Analysis of JUUL-related Tweets (2019 Fall)

Language Used: R (tidyverse, Rtweet)

This was a final project for my Introduction to Sociology course. Motivated by recent social science researches using computational tools to conduct sentiment analysis on social media data, I initiated a mini research on how JUUL usage is perceived on social media. 

## [Bangladesh Well Data Analysis for Policy Suggestion (2018 Fall)](https://github.com/sh4733/Soohyun_Portfolio/tree/main/Bangladesh%20Well%20Data)

This was part of Data Analysis coursework project, and I analyzed 50000+ Bangladesh well data survey results to identify effect of household income and education levels on well-switching behavior.

Using ggplot, I created basic visualizations of the descriptive statistics: 
![alt text](https://github.com/sh4733/Soohyun_Portfolio/blob/main/images/well_data_1.png)

![alt text](https://github.com/sh4733/Soohyun_Portfolio/blob/main/images/well_data_2.png)
