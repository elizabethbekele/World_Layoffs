--- Exploratory Data Analysis

select *
from layoffs_staging;

-- Max total laid off 
select MAX(total_laid_off)
from layoffs_staging;

-- Max total laid off & Max percentage laid off
select MAX(total_laid_off), MAX(percentage_laid_off)
from layoffs_staging;

-- Companies that liad off entire company
select *
from layoffs_staging
where percentage_laid_off = 1;

-- Number of companies that laid off all of their employees
select count(*)
from layoffs_staging
where percentage_laid_off = 1;

-- Of the 116 companies, which had the largest amount of employees
select *
from layoffs_staging
where percentage_laid_off = 1
order by total_laid_off desc; 

-- Funding for companies that laid off entire staff
SELECT *
FROM layoffs_staging
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC; 

-- Data cleaning (funds_raised_millions needs to be of type int not nvarchar)
select *
from layoffs_staging
where percentage_laid_off = 1
order by try_cast(replace(funds_raised_millions, ',', '') as float) desc;

-- Total layoffs grouped by company 

select company, sum(total_laid_off)
from layoffs_staging
group by company 
order by 2 desc;

-- When did layoffs start & when did they last occur? --
select min([date]), max([date])
from layoffs_staging

-- Which industry got hit the hardest? --
select industry, sum(total_laid_off)
from layoffs_staging
group by industry 
order by 2 desc;

select *
from layoffs_staging

-- Which country had the highest # of layoffs? 
select country, sum(total_laid_off)
from layoffs_staging
group by country 
order by 2 desc;

---Layoffs by Year
select year([date]), sum(total_laid_off)
from layoffs_staging
group by year([date])
order by 1 desc;

-- Stage of the Company 
select stage, sum(total_laid_off)
from layoffs_staging
group by stage
order by 1 desc;

select stage, sum(total_laid_off)
from layoffs_staging
group by stage
order by 2 desc;

-- Progression of Layoffs using a rolling sum
select *
from layoffs_staging

-- Data Manipulation on Date column using CTE
with date_cte as 
(
    select total_laid_off,
    convert(varchar, [date], 23) as date_string, -- converts date data type to a string 'YYY-MM-DD' --
    left(convert(varchar, [date], 23), 7) as year_month-- Extracts 'YYYY-MM' --
    from layoffs_staging
)

-- Looking at total layoffs based on months across the 3 years
select year_month, sum(total_laid_off) as total_layoffs
from date_cte
where year_month is not null
group by year_month
order by 1 asc;


-- bringing the first cte that was used to look at total layoffs per month across the 3 years
with date_cte as 
(
select 
    total_laid_off,
    convert(varchar, [date], 23) as date_string, -- converts date data type to a string 'YYY-MM-DD' --
    left(convert(varchar, [date], 23), 7) as year_month-- Extracts 'YYYY-MM' --
from layoffs_staging
),

-- rolling total cte
rolling_total AS
(
select 
    year_month, 
    sum(total_laid_off) as total_layoffs
from date_cte
where year_month is not null
group by year_month
)

-- call rolling total cte
select 
    year_month, 
    total_layoffs,
    sum(total_layoffs) over(order by year_month) as rolling_total
from rolling_total
order by year_month asc;

-- Total layoffs grouped by company per year
select company, year(layoffs_staging.date) as years, sum(total_laid_off) as sum_laid_off
from layoffs_staging
group by company, year(layoffs_staging.date)
order by company asc;

--Years where the most employees were laid off
select company, year(layoffs_staging.date) as years, sum(total_laid_off) as sum_laid_off
from layoffs_staging
group by company, year(layoffs_staging.date)
order by sum_laid_off desc;

-- Rank the years based on number of layoff
with company_year (company, years, total_laid_off) as
(
   select 
        company, 
        year(layoffs_staging.date), 
        sum(total_laid_off)
    from layoffs_staging
    group by company, year(layoffs_staging.date)
), 

Company_Year_Rank as
(
select *, dense_rank() over(partition by years order by total_laid_off desc) as Ranking
from company_year
where years is not null
)

-- Look at the top 5 rankings
select * 
from Company_Year_Rank
where Ranking <=5;