SELECT * FROM Portfolio_Project..CovidDeaths
order by 3,4

Select * from Portfolio_Project..CovidVaccinations
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
order by 1,2

 Totla cases Vs. Total Deaths



USE Portfolio_Project;
GO


ALTER TABLE CovidDeaths ALTER COLUMN population FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN total_cases FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN new_cases FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN new_cases_smoothed FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN new_deaths FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN new_deaths_smoothed FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN total_cases_per_million FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN new_cases_per_million FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN new_cases_smoothed_per_million FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN total_deaths_per_million FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN new_deaths_per_million FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN new_deaths_smoothed_per_million FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN reproduction_rate FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN icu_patients FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN icu_patients_per_million FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN hosp_patients FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN hosp_patients_per_million FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN weekly_icu_admissions FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN weekly_icu_admissions_per_million FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN weekly_hosp_admissions FLOAT;
ALTER TABLE CovidDeaths ALTER COLUMN weekly_hosp_admissions_per_million FLOAT;


USE Portfolio_Project;
GO
ALTER TABLE CovidVaccinations ALTER COLUMN new_tests FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN total_tests FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN total_tests_per_thousand FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN new_tests_per_thousand FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN new_tests_smoothed FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN new_tests_smoothed_per_thousand FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN positive_rate FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN tests_per_case FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN total_vaccinations FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN people_vaccinated FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN people_fully_vaccinated FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN new_vaccinations FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN new_vaccinations_smoothed FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN total_vaccinations_per_hundred FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN people_vaccinated_per_hundred FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN people_fully_vaccinated_per_hundred FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN new_vaccinations_smoothed_per_million FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN stringency_index FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN population_density FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN median_age FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN aged_65_older FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN aged_70_older FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN gdp_per_capita FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN extreme_poverty FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN cardiovasc_death_rate FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN diabetes_prevalence FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN female_smokers FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN male_smokers FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN handwashing_facilities FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN hospital_beds_per_thousand FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN life_expectancy FLOAT;
ALTER TABLE CovidVaccinations ALTER COLUMN human_development_index FLOAT;

SELECT location, date, total_cases, total_deaths, (total_deaths/nullif(total_cases, 0))*100 as Death_Percentage
FROM Portfolio_Project..CovidDeaths
order by 1,2

Loking for Total cases Vs Population: sHOWS WHAT % of population got Covid

SELECT location, date, total_cases, population, (total_cases/nullif(population, 0))*100 as Case_Percentage
FROM Portfolio_Project..CovidDeaths
-- where location like '%India%'
order by 3 asc

 Lets look at countries with highest infection rate compared to population

SELECT location, max(total_cases) as Highest_Infection_Count, max(total_cases/nullif(population, 0))*100 as Infected_Population_Percentage
FROM Portfolio_Project..CovidDeaths
-- where location like '%India%'
Group by location, population
order by Infected_Population_Percentage desc

 countires with the Highest Death Count

SELECT location, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..CovidDeaths
-- where location like '%India%'
where continent is not null and continent <> ''
Group by location
order by Total_Death_Count desc

 break it by continent

SELECT continent, MAX(cast(total_deaths as int)) as Total_Death_Count
FROM Portfolio_Project..CovidDeaths
-- where location like '%India%'
where continent is not null and continent <> ''
Group by continent
order by Total_Death_Count desc

-- Global Numbers


SELECT date, sum(new_cases) as Total_new_cases,  sum(new_deaths) as Total_new_deaths, (sum(new_deaths)*100)/nullif(sum(new_cases), 0) as Death_Percentage
FROM Portfolio_Project..CovidDeaths
-- where location like '%India%'
where continent is not null and continent <> ''
Group by date
order by 1, 2


-- Looking a total population Vs Vaccination

with popvsvac (Continent, Location, Date, Population, New_Vaccination, cumilative_vaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS cumulative_vaccinations
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.continent <> ''
--order by 2,3
)
select *, (cumilative_vaccinations/nullif(Population, 0))*100 as percentage from popvsvac


-- Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated;

CREATE TABLE #PercentPopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_Vaccinations NUMERIC,
    cumilative_vaccinations NUMERIC
);

INSERT INTO #PercentPopulationVaccinated
SELECT 
    dea.continent, 
    dea.location, 
    TRY_CAST(dea.date AS DATETIME) AS date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(vac.new_vaccinations) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS cumilative_vaccinations
FROM 
    Portfolio_Project..CovidDeaths dea
JOIN 
    Portfolio_Project..CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL 
    AND dea.continent <> '';

-- Final Select with Percentage
SELECT *, 
    (cumilative_vaccinations / NULLIF(Population, 0)) * 100 AS percentage 
FROM #PercentPopulationVaccinated;

-- Creating View for Data Vizualizations later

create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (
        PARTITION BY dea.location 
        ORDER BY dea.location, dea.date
    ) AS cumulative_vaccinations
from Portfolio_Project..CovidDeaths dea
join Portfolio_Project..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and dea.continent <> ''
--order by 2,3

select * from percentpopulationvaccinated