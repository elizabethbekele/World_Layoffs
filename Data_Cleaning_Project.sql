-- Runn the code below if having issues creating a new database the model database needs to not be in use when creating a new database
/*SELECT 
    spid,
    status,
    loginame AS LoginName,
    hostname AS HostName,
    db_name(dbid) AS DatabaseName,
    cmd,
    request_id
FROM sys.sysprocesses
WHERE db_name(dbid) = 'model';*/

-- Data Cleaning Project
select *
from layoffs;

--1. Remove Duplicates
--2. Standardize the data
--3. Null values or blank values
--4. Remove columns/rows that aren't necessary 


-- create another table that will have revisions 
select *
into layoffs_staging 
from layoffs;

select *
from layoffs_staging;

-- REMOVE DUPLICATES --

-- add row numbers --
-- cannot use partition by or order by with columns that are of type text so switched out date w/location
select *,
    row_number() over(
        Partition By company, industry, total_laid_off, percentage_laid_off, [location]
        Order by company
    ) as row_num
from layoffs_staging;

-- if the row_num is 2 or above then there are duplicates 

with duplicate_cte AS (
  select *,
    row_number() over(
        Partition By company, [location], industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions
        Order by company
    ) as row_num
  from layoffs_staging  
)

select *
from duplicate_cte
where row_num > 1;

-- confirm duplicates -- 
select *
from layoffs_staging 
where company = 'Casper';

-- Remmove all the duplicates at once 
with duplicate_cte AS (
  select *,
    row_number() over(
        Partition By company, [location], industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions
        Order by company
    ) as row_num
  from layoffs_staging  
)

Delete 
from duplicate_cte
where row_num > 1;

--- check
with duplicate_cte AS (
  select *,
    row_number() over(
        Partition By company, [location], industry, total_laid_off, percentage_laid_off, [date], stage, country, funds_raised_millions
        Order by company
    ) as row_num
  from layoffs_staging  
)

select *
from duplicate_cte
where row_num > 1;

select * 
from layoffs_staging;

-- STANDARDIZING DATA --

select distinct company, trim(company)
from layoffs_staging;

update layoffs_staging 
set company = trim(company);

select * 
from layoffs_staging;

-- Look into industry column and sort alphabetically 
select distinct industry 
from layoffs_staging
order by 1;

-- industries that start with Crypto
select *
from layoffs_staging
where industry like 'Crypto%';

-- set the industry to Crypto for indutries that start with Crypto
update layoffs_staging
set industry = 'Crypto'
where industry like 'Crypto%';

-- check --
select *
from layoffs_staging
where industry like 'Crypto%';

select distinct industry 
from layoffs_staging
order by 1;

-- check the other columns one by one & scan for rows that should be combined
select distinct country
from layoffs_staging
order by 1;

select *
from layoffs_staging
where country like 'United States%'
order by 1;

-- RTRIM() removes all trailing spaces, but not specific characters lilke '.' Use it if you want to remove spaces

select distinct country, 
  rtrim(country) as trimmed_country
from layoffs_staging
order by 1;

-- CASE with RIGHT() and LEFT() 
-- RIGHT(country, 1) checks if the last character is a period (.)
-- If it is, LEFT(country, LEN(country) - 1) removes the last character 
-- Otherwise, the original value of country is returned 

select distinct country,
  case 
    when right(country, 1) = '.' then left(country, len(country)-1)
    else country
  end as trimmed_country
from layoffs_staging
order by 1;

-- changing the country column 
update layoffs_staging
set country = case 
                when right(country, 1) = '.' then left(country, len(country)-1)
                else country
              end
where country like 'United States%';

-- verify
select distinct country 
from layoffs_staging
order by 1;

-- change the format of the date column to Month/Day/Year
-- store it in column Dates
alter table layoffs_staging 
add Dates varchar(50);

update layoffs_staging
set Dates = Convert(VARCHAR, [date], 101);

select *
from layoffs_staging;

alter table layoffs_staging
alter column Dates Date;

select Dates
from layoffs_staging;

-- since date is already a Date data type we can remove the Dates column 
alter table layoffs_staging
drop column Dates;

select *
from layoffs_staging;

-- NULL Values 

-- look at rows where industry is either NULL or blank
select *
from layoffs_staging
where industry is NULL or industry = ' ';

-- look at each company individually to see if the missing data can be populated 
-- Airbnb
select *
from layoffs_staging
where company = 'Airbnb';

-- update the emptry strings in the industry column to be null only 
update layoffs_staging
set industry = NULL
where industry = ' ';

-- looking at the industry column of the self join 

select t1.industry, t2.industry
from layoffs_staging t1
join layoffs_staging t2
 on t1.company = t2.company
where (t1.industry is NULL or t1.industry = '') 
and t2.industry is not null; 

-- update the industry information that is null with the data that is populated for the corresponding company 
update t1
set t1.industry = t2.industry 
from layoffs_staging t1
join layoffs_staging t2
  on t1.company = t2.company
where t1.industry is NULL 
and t2.industry is not null; 

-- check if null is still in industry column 
select *
from layoffs_staging
where industry is NULL or industry = ' ';

-- look into Bally's
select *
from layoffs_staging
where company like 'Bally%';

-- Remove Rows that aren't meaningful

-- Remove rows where total_laid_off & percentaige_laid_off are null 
-- Not meaningful b/c the point of the analysis is to look at companies who did have layoffs 
select *
from layoffs_staging
where total_laid_off is NULL
and percentage_laid_off is NULL;

delete
from layoffs_staging
where total_laid_off is NULL
and percentage_laid_off is NULL;

-- check
select *
from layoffs_staging
where total_laid_off is NULL
and percentage_laid_off is NULL;