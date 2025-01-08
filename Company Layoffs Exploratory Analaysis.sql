CREATE TABLE company_layoffs(
	company CHAR(20),
    location CHAR(30),
    industry CHAR(30),
    total_laid_off SMALLINT,
    percentage_laid_off FLOAT(5,3),
    date_laid_off DATE,
    stage CHAR(30),
    country CHAR(30),
    funds_raised SMALLINT
);

ALTER TABLE company_layoffs
MODIFY COLUMN percentage_laid_off DECIMAL(10,3);

SELECT *
FROM company_layoffs;

-- Find the total number of employees laid off for each industry and sort the results in descending order by the total laid off --
SELECT industry, SUM(total_laid_off) AS total_employees_laid_off
FROM company_layoffs
GROUP BY industry
ORDER BY total_employees_laid_off DESC;

-- Find the total companies in the Healthcare industry --
SELECT industry, COUNT(*) AS total_companies
FROM company_layoffs
WHERE industry = 'Healthcare'
GROUP BY industry;

-- Find industries where the total employees laid off exceeds 20,000 --
SELECT industry, SUM(total_laid_off) AS total_employee_laid_off
FROM company_layoffs
GROUP BY industry
HAVING total_employee_laid_off > 20000;

-- Find industries where the total employees laid off recedes 20,000 --
SELECT industry, SUM(total_laid_off) AS total_employee_laid_off
FROM company_layoffs
GROUP BY industry
HAVING total_employee_laid_off < 20000;

-- Find industries in the United States where the total employees laid off exceeds 1000 --
SELECT industry, country, SUM(total_laid_off) AS total_employees_laid_off
FROM company_layoffs
WHERE country = 'United States'
GROUP BY industry
HAVING total_employees_laid_off > 1000
;

-- Find the top 5 companies with the highest percentage of layoffs --
SELECT country, percentage_laid_off
FROM company_layoffs
ORDER BY percentage_laid_off DESC
LIMIT 5;

-- Find the total amount of funds raised for each stage, and display only those stages where the total funds raised exceed $50,000. 
-- Sort the results in descending order of total funds raised
SELECT stage, SUM(funds_raised) AS total_fund
FROM company_layoffs
GROUP BY stage
HAVING total_fund > 50000
ORDER BY total_fund DESC
;

-- Find the top 5 locations with the highest total number of employees laid off across all industries. 
-- Ensure the results are sorted in descending order of total layoffs.
SELECT location, SUM(total_laid_off) AS total_employee_laid_off
FROM company_layoffs
GROUP BY location
ORDER BY total_employee_laid_off DESC
LIMIT 5;

-- Find the percentage of layoffs for each industry compared to the total number of layoffs across all industries. 
-- Display only industries where this percentage is greater than 10%, and sort the results in descending order of the percentage
SELECT industry, SUM(total_laid_off) AS total_laid_off_by_industry,
    (SUM(total_laid_off) / (SELECT SUM(total_laid_off) FROM company_layoffs) * 100) AS percentage_of_total
FROM company_layoffs
GROUP BY industry
HAVING percentage_of_total > 10
ORDER BY percentage_of_total DESC;

-- Find the average percentage of layoffs for each stage. 
-- Only include stages where the average percentage of layoffs is greater than 5%. Sort the results in ascending order of the average percentage.
SELECT stage, AVG(percentage_laid_off) AS average_percentage_laid_off
FROM company_layoffs
GROUP BY stage
HAVING average_percentage_laid_off > 0.05
ORDER BY average_percentage_laid_off ASC;

-- Find the total number of companies and the total funds raised for each country. 
-- Only include countries where the total funds raised exceed $20,000. Sort the results in descending order of total funds raised.
SELECT country, COUNT(*) AS total_companies, SUM(funds_raised) AS total_funds_raised
FROM company_layoffs
GROUP BY country
HAVING total_funds_raised > 20000
ORDER BY total_funds_raised DESC
;

-- List all companies along with their respective countries and stages. 
-- Ensure that each company appears only once. Sort the results alphabetically by company name.
SELECT DISTINCT company, stage, country
FROM company_layoffs
ORDER BY company ASC;

-- You want to combine two datasets from the same table: Companies located in the United States, Companies that are in the Post-IPO stage.
-- Create a query that combines these two datasets, ensuring no duplicates are included. Sort the results alphabetically by company name.
SELECT company, country, stage
FROM company_layoffs
WHERE country = 'United States'
UNION
SELECT company, country, stage
FROM company_layoffs
WHERE stage = 'Post-IPO'
ORDER BY company ASC
;

-- For each company, display the company name in uppercase and the first three characters of the country. 
-- Label these columns as company_name_upper and country_code. Sort the results alphabetically by the country_code
SELECT UPPER(company) AS company_name_upper, LEFT(country, 3) AS country_code
FROM company_layoffs
ORDER BY country_code ASC;

-- Create a query that classifies companies into three categories based on the percentage of layoffs:
-- "High Layoff" if the percentage of layoffs is greater than 20%.
-- "Moderate Layoff" if the percentage of layoffs is between 10% and 20% (inclusive).
-- "Low Layoff" if the percentage of layoffs is less than 10%.
-- Display the company name and its classification as layoff_category. Sort the results by layoff_category
SELECT company,
CASE
	WHEN percentage_laid_off > 0.20 THEN 'High layoff'
    WHEN percentage_laid_off BETWEEN 0.10 AND 0.20 THEN 'Moderate Layoff'
    ELSE 'Low Layoff'
END AS layoff_category
FROM company_layoffs
ORDER BY layoff_category
;

-- Find the companies that raised more funds than the average funds raised across all companies. 
-- Display the company name, funds raised, and the difference between the company's funds raised and the average. 
-- Label this difference as funds_difference. Sort the results by funds_difference in descending order.
SELECT company, funds_raised, (funds_raised - (SELECT AVG(funds_raised) FROM company_layoffs)) AS funds_difference
FROM company_layoffs
WHERE funds_raised > (SELECT AVG(funds_raised) FROM company_layoffs)
ORDER BY funds_difference DESC;

-- For each company, calculate the total funds raised by all companies in the same country. 
-- Display the company name, country, funds raised, and the total funds raised by country. Sort the results by country and company name
SELECT company, country, funds_raised, 
		SUM(funds_raised) OVER (PARTITION BY country) AS total_fund_raised
FROM company_layoffs
ORDER BY country, company
;

-- Write a queries to get the first 10 rows of the table to understand its structure.
SELECT *
FROM company_layoffs
LIMIT 10;

-- Count the number of unique companies, locations, and industries
SELECT COUNT(company) AS company_count, COUNT(location) AS location_count, COUNT(industry) AS industry_count
FROM company_layoffs
;

-- Find the minimum, maximum, and average values for total_laid_off
SELECT MIN(total_laid_off) AS minimum_total_laid_off, MAX(total_laid_off) AS maximum_total_laid_off, AVG(total_laid_off) AS average_total_laid_off
FROM company_layoffs
;

-- Find the minimum, maximum, and average values for percentage_laid_off
SELECT MIN(percentage_laid_off) AS minimum_percentage_laid_off, MAX(percentage_laid_off) AS maximum_percentage_laid_off, AVG(percentage_laid_off) AS average_percentage_laid_off
FROM company_layoffs
;

-- Analyze layoffs over time by grouping data by date and summing total_laid_off
SELECT date_laid_off, SUM(total_laid_off) AS sum_total_laid_off
FROM company_layoffs
GROUP BY date_laid_off;

-- Identify months with the highest and lowest layoffs.
SELECT DATE_FORMAT(date_laid_off, '%Y-%m') AS months, SUM(total_laid_off) AS sum_total_laid_off
FROM company_layoffs
GROUP BY months
ORDER BY sum_total_laid_off DESC
LIMIT 1
;

SELECT DATE_FORMAT(date_laid_off, '%Y-%m') AS months, SUM(total_laid_off) AS sum_total_laid_off
FROM company_layoffs
GROUP BY months
ORDER BY sum_total_laid_off ASC
LIMIT 1
;

-- Aggregate layoffs by country and location to see geographical trends.
SELECT country, location, SUM(total_laid_off) AS overall_total_laid_off
FROM company_layoffs
GROUP BY country, location
ORDER BY overall_total_laid_off;

-- Identify the country with the highest layoffs as a percentage of its workforce.
SELECT country, SUM(percentage_laid_off) AS total_percentage_laid_off
FROM company_layoffs
GROUP BY country
ORDER BY total_percentage_laid_off DESC
LIMIT 1;

-- Determine which company stages are most affected by layoffs.
SELECT stage, SUM(total_laid_off) AS overall_total_laid_off
FROM company_layoffs
GROUP BY stage
ORDER BY overall_total_laid_off DESC
;

-- Compare layoffs in companies with high funds_raised versus low funds_raised.
SELECT company,
CASE
	WHEN funds_raised > 
		(SELECT AVG(funds_raised) FROM company_layoffs) THEN 'High Fund Raised'
    ELSE 'Low Fund Raised'
END AS fund_raised_category
FROM company_layoffs
ORDER BY fund_raised_category
;

-- Identify the top 10 companies with the highest number of layoffs.
SELECT company, total_laid_off
FROM company_layoffs
ORDER BY total_laid_off DESC
LIMIT 10
;

-- Highlight the top 5 industries contributing to the majority of layoffs.
SELECT industry, SUM(total_laid_off) AS overall_total_laid_off
FROM company_layoffs
GROUP BY industry
ORDER BY overall_total_laid_off DESC
LIMIT 5
;

-- Identify companies with extremely high or low percentage_laid_off compared to the average for their industry or country.
SELECT company, industry, 
CASE
	WHEN percentage_laid_off > 
		(SELECT AVG(percentage_laid_off) AS average_percentage_laid_off FROM company_layoffs) THEN 'High'
	ELSE 'Low'
END AS percentage_laid_off_category
FROM company_layoffs
ORDER BY industry
;

-- Create a summary table with total layoffs, average percentage laid off, and the number of companies for each industry.
SELECT industry, SUM(total_laid_off) AS overall_total_laid_off, AVG(percentage_laid_off) AS average_percentage_laid_off, 
		COUNT(company) AS company_count
FROM company_layoffs
GROUP BY industry
;



