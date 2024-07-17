---<<<HERE WE ARE GONNA WORK WITH COVID DEATHS SPREAD SHEET>>>>-----
Select *
from portfolio.dbo.CovidDeaths
--where location like '%Afg%'

--Looking into the total number of worldwide deaths

Select SUM(CAST(total_deaths as DECIMAL(18,2))) as TOTAL_DEATHS
from portfolio..CovidDeaths

--Looking into the total number of worldwide cases

Select SUM(CAST(total_cases as DECIMAL(18,2))) as TOTAL_CASES
from portfolio..CovidDeaths

--What was the percentage of total death and population

Select continent, location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio..CovidDeaths
where location like '%sudan%'
order by death_percentage DESC

--Looking at the maximum death percentage we had region wise
Select location, MAX(CAST(total_deaths as float)/cast(total_cases as float)*100) as max_death_percentage
from portfolio..CovidDeaths
--where location like '%india%'
group by location
order by max_death_percentage DESC

--Showing what percentage of the population got covid

Select continent, location,date, total_cases, total_deaths, population, (total_cases/population)*100 as population_percent
from portfolio..CovidDeaths
where location like '%states%'
order by 2,3


--Lets look at the countries with the highest infection rate compared to the population
Select location, population, MAX(total_cases) as HighestInfection,  MAX(CAST(total_cases as float)/cast(population as float)*100) as percentpopulation_infected
from portfolio..CovidDeaths
group by location, population
order by 4 DESC

--Look into the number of Hospital patients and weekly ICU admissions and weekly hospital admission

Select location, population, MAX(hosp_patients) as Highest_PatientsCount, MAX(weekly_icu_admissions) as ICUCount_weekly, MAX(weekly_hosp_admissions) as MAX_WeeklyHospital
from portfolio..CovidDeaths
group by location, population
order by 1,2

--Showing countries with the highest death count per population

Select location, population, MAX(CAST(total_deaths as float)) as TOTALDEATHCOUNT, MAX(CAST(total_deaths as float)/CAST(population as float)*100) as DeathCount_perPopulation
from portfolio..CovidDeaths
where continent is not null
group by location, population
order by 3 DESC


--Looking at the total death toll over the continents this shows world as well

Select location, population, MAX(CAST(total_deaths as float)) as TOTALDEATHCOUNT
from portfolio..CovidDeaths
where continent is null
group by location, population
order by 3 DESC

--Looking at continents death counts only

Select continent, MAX(CAST(total_deaths as float)) as TOTALDEATHCOUNT
from portfolio..CovidDeaths
where continent is not null
group by continent

--The positivity rate region wise

Select location, population, MAX(positive_rate) as Positive_rate
from portfolio..CovidDeaths
group by location, population
order by 3 DESC

--Relation with the GDP Per capita and the cases

SELECT 
    location, 
    CAST(population AS FLOAT) AS population, 
    MAX(CAST(total_deaths AS FLOAT)) AS TOTALDEATHCOUNT, 
    MAX(CAST(total_cases AS FLOAT)) AS TOTALCASECOUNT,
    AVG(CAST(gdp_per_capita AS FLOAT)) AS Avg_GDP_per_Capita,
    (SUM(CAST(total_deaths AS FLOAT)) / CAST(population AS FLOAT)) * 100 AS DeathCount_perPopulation,
    (SUM(CAST(total_cases AS FLOAT)) / CAST(population AS FLOAT)) * 100 AS CaseCount_perPopulation
FROM 
    portfolio..CovidDeaths
WHERE
	continent is not null
GROUP BY 
    location, population
ORDER BY 
    Avg_GDP_per_Capita DESC




