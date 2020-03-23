# Uber-data-analysis

we will analyze the Uber Pickups in New York City dataset. This is more of a data visualization project that will guide you towards using the ggplot2 library for understanding the data and for developing an intuition for understanding the customers who avail the trips. 

To run the project , You need to follow the above steps:

1. Importing the Essential Packages

In the first step of our R project, we will import the essential packages that we will use in this uber data analysis project. Some of the important libraries of R that we will use are –

ggplot2:
This is the backbone of this project. ggplot2 is the most popular data visualization library that is most widely used for creating aesthetic visualization plots.

ggthemes:
This is more of an add-on to our main ggplot2 library. With this, we can create better create extra themes and scales with the mainstream ggplot2 package.

lubridate:
Our dataset involves various time-frames. In order to understand our data in separate time categories, we will make use of the lubridate package.

dplyr:
This package is the lingua franca of data manipulation in R.

tidyr:
This package will help you to tidy your data. The basic principle of tidyr is to tidy the columns where each variable is present in a column, each observation is represented by a row and each value depicts a cell.

DT:
With the help of this package, we will be able to interface with the JavaScript Library called – Datatables.

scales:
With the help of graphical scales, we can automatically map the data to the correct scales with well-placed axes and legends.

shiny:
Shiny is an R package that makes it easy to build interactive web apps straight from R. You can host standalone apps on a webpage or embed them in R Markdown documents or build dashboards.

ShinyDashboard:
It helps users to build dashboard easily and contains lot more features



2. Download the dataset from this link https://drive.google.com/file/d/1emopjfEkTt59jJoBH9L9bSdmlDC4AR87/view

3. this project contains two R file i.e app.R(which contains GUI and Server code) and uber_analysis.R (it contains all the pre-processing of the 	dataset)

4. In R studio set the working of the given folder and run the app
