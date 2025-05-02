# World_Layoffs

To understand global layoff trends across industries, SQL can be effectively used for both data cleaning and exploratory data analysis (EDA). The process typically involves working with datasets that include fields such as company name, industry, country, date of layoff, number of employees laid off, and total company size.

## Data Cleaning
The cleaning process ensures consistency, accuracy, and completeness in the dataset. Key SQL techniques include:

Handling Missing Values: Using IS NULL to identify missing data and applying COALESCE() or filtering them out as appropriate.

Removing Duplicates: Leveraging ROW_NUMBER() or DISTINCT to identify and eliminate duplicate records.

Standardizing Formats: Ensuring consistent date formats using CAST() or CONVERT(), and standardizing text case using LOWER() or UPPER().

Fixing Inconsistencies: Correcting industry names or country entries with inconsistent spelling via UPDATE and WHERE.

## Exploratory Data Analysis (EDA)
EDA helps uncover patterns, trends, and outliers. SQL queries can be used to:

Identify Trends Over Time: Using GROUP BY with YEAR(date) or MONTH(date) to view layoffs over time.

Industry-wise Analysis: Aggregating total layoffs per industry using GROUP BY industry, highlighting sectors most impacted.

Geographical Insights: Analyzing layoffs by country or region to detect geographic trends.

Company Size Impact: Comparing layoff ratios (employees_laid_off / total_employees) across different company sizes.

Top Companies Affected: Sorting and limiting results with ORDER BY and LIMIT to find companies with the most layoffs.

SQL's aggregation functions (SUM(), AVG(), COUNT()), conditional logic (CASE), and joins allow comprehensive analysis even across multiple related tables.
