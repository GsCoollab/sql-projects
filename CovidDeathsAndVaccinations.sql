SELECT * FROM `electric-goods-397906.covid19.CovidDeaths`
order by 3, 4;

-- SELECT * FROM `electric-goods-397906.covid19.CovidVaccinations`
-- order by 3, 4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `electric-goods-397906.covid19.CovidDeaths`
order by 1, 2;

-- Looking at Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM `electric-goods-397906.covid19.CovidDeaths`
where location LIKE '%States%'
order by 1, 2;

-- Looking at Total Cases vs Population
SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionRate
FROM `electric-goods-397906.covid19.CovidDeaths`
-- where location LIKE '%States%'
order by 1, 2;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as HighestInfectionRate
FROM `electric-goods-397906.covid19.CovidDeaths`
-- where location LIKE '%States%'
GROUP BY location, population
order by HighestInfectionRate desc;

-- Looking at Countries with Highest Death Count
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM `electric-goods-397906.covid19.CovidDeaths`
-- where location LIKE '%States%'
Where continent is not NULL
GROUP BY location
order by TotalDeathCount desc;

-- Showing continent with the highest death count
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM `electric-goods-397906.covid19.CovidDeaths`
Where continent is not NULL
GROUP BY continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
(CASE WHEN SUM(new_cases)>0 THEN SUM(new_deaths)/SUM(new_cases)*100
ELSE null END) as DeathPercentage
FROM `electric-goods-397906.covid19.CovidDeaths`
where continent is not NULL
GROUP BY date
order by 1, 2;

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, 
(CASE WHEN SUM(new_cases)>0 THEN SUM(new_deaths)/SUM(new_cases)*100
ELSE null END) as DeathPercentage
FROM `electric-goods-397906.covid19.CovidDeaths`
where continent is not NULL
order by 1, 2;

SELECT * FROM `electric-goods-397906.covid19.CovidVaccinations`;

-- JOIN TWO TABLES
-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM `electric-goods-397906.covid19.CovidDeaths` dea
JOIN `electric-goods-397906.covid19.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not NULL
order by 2,3;

-- USE CTE
WITH pop_vs_vac 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
FROM `electric-goods-397906.covid19.CovidDeaths` dea
JOIN `electric-goods-397906.covid19.CovidVaccinations` vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not NULL
)
SELECT *, (rolling_vaccinations/population)*100 as accumulated_vaccination_rate
FROM pop_vs_vac
order by 2,3;


-- TEMP TABLE
CREATE TEMP TABLE PercentPopulationVaccinated 
(
Continent STRING,
Location STRING,
Date datetime,
Population INTEGER,
New_vaccinations INTEGER,
rolling_vaccinations INTEGER
)
AS
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
  FROM `electric-goods-397906.covid19.CovidDeaths` dea
  JOIN `electric-goods-397906.covid19.CovidVaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent is not NULL
;
SELECT *, (rolling_vaccinations/population)*100 as accumulated_vaccination_rate
FROM PercentPopulationVaccinated
order by 2,3;


-- Creating View to store data for later visualisations
CREATE VIEW electric-goods-397906.covid19.PercentPopulationVaccinated(continent, location, date, population, new_vaccinations, rolling_vaccinations) 
AS 
(
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_vaccinations
  FROM `electric-goods-397906.covid19.CovidDeaths` dea
  JOIN `electric-goods-397906.covid19.CovidVaccinations` vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE dea.continent is not NULL
  order by 2,3
);

SELECT * FROM `covid19.PercentPopulationVaccinated`;