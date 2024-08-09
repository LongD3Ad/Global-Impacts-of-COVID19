---<<<<< We will now start getting the Vaccinations table involved >>>>>>---------

Select *
from portfolio..CovidVaccinations
--where continent like '%Asia%'
order by 1,2

--Joining the two tables based on the location and date to be more specific

Select *
from portfolio..CovidDeaths DEA
join portfolio..CovidVaccinations VAC
on DEA.location = VAC.location
and DEA.date = VAC.date

--Now that the joining was successful we can start looking into how the vaccinations helped the world

--Select location, population, MAX(total_tests) as MAXIMUM_totaltest, MAX(people_vaccinated) as VACCINATED, MAX(people_fully_vaccinated) as COMPLETE_VACCINE, MAX(new_tests) as NEWLYTESTED, MAX(total_tests) as TOTAL_newTESTS, MAX(positive_rate) as PositiveRate
--from portfolio..CovidDeaths DEA
---join portfolio..CovidVaccinations VAC
---on DEA.location = VAC.location
---and DEA.date = VAC.date

--ABOVE CODE WAS A FLOP ----

--NEW CODE---

SELECT 
    DEA.location, 
    DEA.population, 
    MAX(DEA.total_cases) AS MAXIMUM_total_cases, 
    MAX(VAC.people_vaccinated) AS VACCINATED, 
    MAX(VAC.people_fully_vaccinated) AS COMPLETE_VACCINE, 
    MAX(DEA.new_tests) AS NEWLYTESTED, 
    MAX(DEA.total_tests) AS TOTAL_newTESTS, 
    MAX(DEA.positive_rate) AS PositiveRate
FROM 
    portfolio..CovidDeaths DEA
JOIN 
    portfolio..CovidVaccinations VAC
ON 
    DEA.location = VAC.location
AND 
    DEA.date = VAC.date
GROUP BY 
    DEA.location, DEA.population
ORDER BY 
    DEA.location


--Now we will see what is the positivity rate and death tolls worldwide after administering the vaccinations
--We will also summarise the data before and after vaccinations
---Calculate the date when each location reaches 50% vaccination using population from CovidDeaths ---

WITH VaccinationData AS (
    SELECT 
        VAC.location, 
        VAC.date, 
        CAST(VAC.people_fully_vaccinated AS FLOAT) AS people_fully_vaccinated, 
        CAST(DEA.population AS FLOAT) AS population
    FROM 
        portfolio..CovidVaccinations VAC
    JOIN 
        portfolio..CovidDeaths DEA ON VAC.location = DEA.location AND VAC.date = DEA.date
),
VaccinationThreshold AS (
    SELECT 
        location, 
        date, 
        (people_fully_vaccinated / population) * 100 AS fully_vaccinated_percentage
    FROM 
        VaccinationData
),
ThresholdDates AS (
    SELECT 
        location, 
        MIN(date) AS vaccination_threshold_date
    FROM 
        VaccinationThreshold
    WHERE 
        fully_vaccinated_percentage >= 0
    GROUP BY 
        location
)
SELECT 
    DEA.location, 
    MAX(CASE WHEN DEA.date < TD.vaccination_threshold_date THEN CAST(DEA.total_deaths AS FLOAT) ELSE 0 END) AS deaths_before_vaccination,
    MAX(CASE WHEN DEA.date >= TD.vaccination_threshold_date THEN CAST(DEA.total_deaths AS FLOAT) ELSE 0 END) AS deaths_after_vaccination,
    AVG(CASE WHEN DEA.date < TD.vaccination_threshold_date THEN CAST(DEA.positive_rate AS FLOAT) ELSE NULL END)*100 AS avg_positive_rate_before_vaccination,
    AVG(CASE WHEN DEA.date >= TD.vaccination_threshold_date THEN CAST(DEA.positive_rate AS FLOAT) ELSE NULL END)*100 AS avg_positive_rate_after_vaccination
FROM 
    portfolio..CovidDeaths DEA
JOIN 
    ThresholdDates TD ON DEA.location = TD.location
GROUP BY 
    DEA.location
ORDER BY 
    DEA.location



--Lets look at the total population and how many vaccines were administred per day

select DEA.continent, DEA.location, DEA.date ,DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations as int)) OVER (Partition by DEA.location order by DEA.location, DEA.date) as total_vaccine_sum
from portfolio..CovidDeaths DEA
join portfolio..CovidVaccinations VAC
on DEA.location =  VAC.location
and DEA.date = VAC.date
where DEA.continent is not null
order by 2,3

--USING CTE

WITH pvsv AS (
    SELECT 
        DEA.continent, 
        DEA.location, 
        DEA.date, 
        DEA.population, 
        VAC.new_vaccinations, 
        SUM(CAST(VAC.new_vaccinations AS INT)) OVER (PARTITION BY DEA.location ORDER BY DEA.date) AS total_vaccine_sum
    FROM 
        portfolio..CovidDeaths DEA
    JOIN 
        portfolio..CovidVaccinations VAC
        ON DEA.location = VAC.location
        AND DEA.date = VAC.date
    WHERE 
        DEA.continent IS NOT NULL
)
SELECT *, (total_vaccine_sum/population)*100 as vaccine_percent
FROM pvsv
ORDER BY location, date


--Making a temp table for more access
--NOTE if we are making any changes to the temp table we can use the drop statement to make sure we avoid any errors being made
drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 total_vaccine_sum numeric)

insert into #PercentPopulationVaccinated
select DEA.continent, DEA.location, DEA.date ,DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations as int)) OVER (Partition by DEA.location order by DEA.location, DEA.date) as total_vaccine_sum
from portfolio..CovidDeaths DEA
join portfolio..CovidVaccinations VAC
on DEA.location =  VAC.location
and DEA.date = VAC.date
where DEA.continent is not null
--and DEA.location like '%india%'
order by 2,3

SELECT *, (total_vaccine_sum/population)*100 as vaccine_percent
FROM #PercentPopulationVaccinated
ORDER BY location, date

--Making a view table for the total death count worldwide

--Looking at continents death counts only
--The go command is used to separate the sql commands

GO 

Create view ContinentDeathMax as 
Select continent, MAX(CAST(total_deaths as float)) as TOTALDEATHCOUNT
from portfolio..CovidDeaths
where continent is not null
group by continent

GO

Select *
from ContinentDeathMax

--------Making another View table --------

GO

Create view PercentPopulationView as 
select DEA.continent, DEA.location, DEA.date ,DEA.population, VAC.new_vaccinations, SUM(CAST(VAC.new_vaccinations as int)) OVER (Partition by DEA.location order by DEA.location, DEA.date) as total_vaccine_sum
from portfolio..CovidDeaths DEA
join portfolio..CovidVaccinations VAC
on DEA.location =  VAC.location
and DEA.date = VAC.date
where DEA.continent is not null
--and DEA.location like '%india%'

GO

Select *
from PercentPopulationView
order by 2,3


