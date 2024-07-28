/* -- Project Introduction -- */

/* This project delves into the real-world Covid-19 dataset provided by "Our World in Data". The dataset, 
available here (https://ourworldindata.org/covid-deaths), originally contains both death and vaccination data. 
For the purposes of this analysis, the dataset was split into two separate Excel files: one for deaths and one 
for vaccinations.

-- Objectives
 The primary goal of this project is to thoroughly explore the dataset, clean and organize the data, and 
 uncover meaningful insights and patterns related to COVID-19.

-- Key Elements of the Dataset
 * Granularity: Each row represents a single day's data from various locations around the world.
 * Cumulative Data: The numbers in the dataset accumulate day by day for each location.
 * Time Span: The dataset covers the period from January 1, 2020, to November 18, 2022.
 * Data Challenges: The dataset is messy and contains a variety of data types, NULL values, "-", and other 
                    inconsistencies that need to be addressed.

-- Approach
 * Data Cleaning: Handle various data types, NULL values, and inconsistencies to ensure data integrity.
 * Data Organization: Structure the data in a way that facilitates analysis.
 * Exploratory Data Analysis: Dive into the data to identify trends, patterns, and potential insights related 
                              to COVID-19 deaths and vaccinations.

By the end of this project, I aim to present a comprehensive analysis of the Covid-19 data, shedding light on 
critical aspects of the pandemic's impact across different locations and time periods.

-- Expected Outcomes
 * Identify trends and patterns in COVID-19 cases and deaths over time.
 * Determine the impact of vaccinations on the spread and fatality of the virus.
 * Compare the pandemic's effect across different continents and countries.
*/

USE Datasets;

-- covid death data
SELECT *
FROM covid_deaths;

-- covid vaccinations data
SELECT *
FROM covid_vaccinations;

--- View table properties:
EXEC sp_spaceused 'covid_deaths';
EXEC sp_spaceused 'covid_vaccinations';

-- the spilt works fine and we have the same number of rows as well

-- dates check
SELECT date
FROM covid_deaths
ORDER BY 1;

--- View column names:
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid_deaths';  

--------------------------------------------------------------------------------------------------

/* -- Data Preprocessing - covid_deaths data -- */

--- Describe columns of a specific table:
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid_deaths';

-- Step 1: Identify problematic rows
SELECT *
FROM covid_deaths
WHERE 
    TRY_CONVERT(INT, total_cases) IS NULL AND total_cases IS NOT NULL
    OR TRY_CONVERT(INT, new_cases) IS NULL AND new_cases IS NOT NULL
    OR TRY_CONVERT(INT, total_deaths) IS NULL AND total_deaths IS NOT NULL
    OR TRY_CONVERT(INT, new_deaths) IS NULL AND new_deaths IS NOT NULL
    OR TRY_CONVERT(FLOAT, reproduction_rate) IS NULL AND reproduction_rate IS NOT NULL;

-- Step 2: Clean the data
UPDATE covid_deaths
SET 
    total_cases = CASE WHEN TRY_CONVERT(INT, total_cases) IS NOT NULL THEN total_cases ELSE NULL END,
    new_cases = CASE WHEN TRY_CONVERT(INT, new_cases) IS NOT NULL THEN new_cases ELSE NULL END,
    total_deaths = CASE WHEN TRY_CONVERT(INT, total_deaths) IS NOT NULL THEN total_deaths ELSE NULL END,
    new_deaths = CASE WHEN TRY_CONVERT(INT, new_deaths) IS NOT NULL THEN new_deaths ELSE NULL END,
    reproduction_rate = CASE WHEN TRY_CONVERT(FLOAT, reproduction_rate) IS NOT NULL THEN reproduction_rate ELSE NULL END;

-- Step 3: Verify data cleanliness
SELECT *
FROM covid_deaths
WHERE 
    TRY_CONVERT(INT, total_cases) IS NULL AND total_cases IS NOT NULL
    OR TRY_CONVERT(INT, new_cases) IS NULL AND new_cases IS NOT NULL
    OR TRY_CONVERT(INT, total_deaths) IS NULL AND total_deaths IS NOT NULL
    OR TRY_CONVERT(INT, new_deaths) IS NULL AND new_deaths IS NOT NULL
    OR TRY_CONVERT(FLOAT, reproduction_rate) IS NULL AND reproduction_rate IS NOT NULL;

-- Step 4: Change column types
ALTER TABLE covid_deaths ALTER COLUMN total_cases INT;
ALTER TABLE covid_deaths ALTER COLUMN new_cases INT;
ALTER TABLE covid_deaths ALTER COLUMN total_deaths INT;
ALTER TABLE covid_deaths ALTER COLUMN new_deaths INT;
ALTER TABLE covid_deaths ALTER COLUMN reproduction_rate FLOAT;

--- Delete unusable columns
ALTER TABLE covid_deaths 
DROP COLUMN 
new_cases_smoothed,
new_deaths_smoothed,
total_cases_per_million,
new_cases_per_million,
new_cases_smoothed_per_million,
total_deaths_per_million,
new_deaths_per_million,
new_deaths_smoothed_per_million,
icu_patients,
icu_patients_per_million,
hosp_patients,
hosp_patients_per_million,
weekly_icu_admissions,
weekly_icu_admissions_per_million,
weekly_hosp_admissions,
weekly_hosp_admissions_per_million;

-- Cheaking the results of the cleaning
Select *
From covid_deaths;

--- Describe columns of a specific table:
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid_deaths';

-- To sum up, I use very specific columns after it is clean and in the correct format

--------------------------------------------------------------------------------------------------

/* -- Data Preprocessing - covid_vaccinations data -- */

--- Describe columns of a specific table:
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid_vaccinations'

Select *
From covid_vaccinations

--- View column names:
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid_vaccinations'  

--- Delete unusable columns
ALTER TABLE covid_vaccinations 
DROP COLUMN
total_tests_per_thousand
,new_tests_per_thousand
,new_tests_smoothed
,new_tests_smoothed_per_thousand
,positive_rate
,tests_per_case
,tests_units
,total_vaccinations
,people_vaccinated
,people_fully_vaccinated
,total_boosters
,new_vaccinations_smoothed
,total_vaccinations_per_hundred
,people_vaccinated_per_hundred
,people_fully_vaccinated_per_hundred
,total_boosters_per_hundred
,new_vaccinations_smoothed_per_million
,new_people_vaccinated_smoothed
,new_people_vaccinated_smoothed_per_hundred
,stringency_index
,population_density
,median_age
,aged_65_older
,aged_70_older
,gdp_per_capita
,extreme_poverty
,cardiovasc_death_rate
,diabetes_prevalence
,female_smokers
,male_smokers
,handwashing_facilities
,hospital_beds_per_thousand
,life_expectancy
,human_development_index
,excess_mortality_cumulative_absolute
,excess_mortality_cumulative
,excess_mortality
,excess_mortality_cumulative_per_million;

--- View column names:
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid_vaccinations'  

SELECT *
FROM covid_vaccinations

-- Step 1: Identify problematic rows
SELECT *
FROM covid_vaccinations
WHERE 
    TRY_CONVERT(INT, total_tests) IS NULL AND total_tests IS NOT NULL
    OR TRY_CONVERT(INT, new_tests) IS NULL AND new_tests IS NOT NULL;			

-- Step 2: Clean the data
UPDATE covid_vaccinations
SET 
    date = CASE WHEN TRY_CONVERT(date, date) IS NOT NULL THEN date ELSE NULL END,
	total_tests = CASE WHEN TRY_CONVERT(INT, total_tests) IS NOT NULL THEN total_tests ELSE NULL END,
    new_tests = CASE WHEN TRY_CONVERT(INT, new_tests) IS NOT NULL THEN new_tests ELSE NULL END,
	new_vaccinations = CASE WHEN TRY_CONVERT(INT, new_vaccinations) IS NOT NULL THEN new_vaccinations ELSE NULL END;

-- Step 3: Verify data cleanliness
SELECT *
FROM covid_vaccinations
WHERE 
    TRY_CONVERT(INT, total_tests) IS NULL AND total_tests IS NOT NULL
    OR TRY_CONVERT(INT, new_tests) IS NULL AND new_tests IS NOT NULL;

-- Step 4: Change column types
ALTER TABLE covid_vaccinations ALTER COLUMN date date;
ALTER TABLE covid_vaccinations ALTER COLUMN total_tests INT;
ALTER TABLE covid_vaccinations ALTER COLUMN new_tests INT;
ALTER TABLE covid_vaccinations ALTER COLUMN new_vaccinations INT;

--- Describe columns of a specific table:
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'covid_vaccinations'

SELECT *
FROM covid_vaccinations

-- The 'covid_vaccinations' dataset is cleaned and ready for further analysis

--------------------------------------------------------------------------------------------------
	
/* -- Data Analysis -- */

/* -- The analysis covers a variety of insights, such as total cases vs. deaths, infection rates, and 
	  comparisons across locations.
   -- Use of window functions and common table expressions (CTEs).
   -- Temporary tables and views to store intermediate results for further analysis.*/

-- Ordering by location and date 
SELECT *
FROM covid_deaths
WHERE continent is not Null -- Eliminating continent which is not null
ORDER BY 3,4 

SELECT 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
FROM covid_deaths
WHERE continent is not Null
ORDER BY 1,2 

-- Total Cases vs Total Death
-- Shows the likelihood of dying if you contract COVID-19 in your country
SELECT 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 AS death_percentage -- calculates the percentage of deaths out of total cases
FROM covid_deaths
WHERE 
	location like '%state%' and continent is not Null -- filters USA
ORDER BY 1,2 

-- Total Cases vs Population
-- Shows what percentage of the population got COVID
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_pop_inf
FROM covid_deaths
--Where location like '%state%'
WHERE continent is not Null
ORDER BY 1,2 

-- Countries with the highest infection rate compared to the population
SELECT location, population, MAX(new_cases) AS highest_inf_count, MAX((new_cases/population))*100 AS percent_pop_inf
FROM covid_deaths
--Where location like '%state%'
WHERE continent is not Null
GROUP BY population, location
ORDER BY 4 DESC

-- Countries with the highest death Count per population
SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM covid_deaths
--Where location like '%state%'
WHERE continent is not Null
GROUP BY location
ORDER BY 2 DESC

-- Continent with the highest death Count per population
SELECT continent, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM covid_deaths
--Where location like '%state%'
WHERE continent is not Null
GROUP BY continent
ORDER BY 2 DESC

-- Global Numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths, 
		SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent is not Null
--GROUP BY date
ORDER BY 1,2

--Merging the dataset
SELECT *
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Populations vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY 
		dea.location, dea.date) AS rolling_people_vaccinated 
		--, (rolling_people_vaccinated/population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3

-- Use CTE
WITH pop_vs_vac(continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY 
		dea.location, dea.date) as rolling_people_vaccinated 
		--, (rolling_people_vaccinated/population)*100
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (rolling_people_vaccinated/population)*100 AS percent_people_vaccinated
FROM pop_vs_vac

-- Temp Table
--Drop table, if exists , #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric, 
rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CAST(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY 
		dea.location, dea.date) AS rolling_people_vaccinated 
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_people_vaccinated/population)*100 AS percent_people_vaccinated
FROM #PercentPopulationVaccinated
ORDER BY 1,2,3

-- Creating a View to store data for later visualizations
DROP VIEW PercentPopulationVaccinated
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY 
		dea.location, dea.date) AS rolling_people_vaccinated 
FROM covid_deaths dea
JOIN covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1, 2

SELECT *
FROM PercentPopulationVaccinated
