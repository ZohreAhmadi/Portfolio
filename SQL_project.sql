
--checking the current version

SELECT @@version

--checking imported data
SELECT *
FROM Portfolio..Death
WHERE continent is not null
ORDER BY 3,4

SELECT *
FROM Portfolio..Vaccination
WHERE continent is not null
ORDER BY 3, 4

--Select data

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Death
WHERE continent is not null
ORDER BY 1, 2


--Looking at Total cases vs Total Deaths


SELECT Location, date, total_cases, total_deaths
FROM portfolio..Death
WHERE continent is not null


SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portfolio..Death
WHERE location LIKE 'Canada'
ORDER BY 1, 2


--changing data type

USE Portfolio
ALTER TABLE dbo.Death
ALTER COLUMN total_cases float


--Looking at total cases vs population
--Shows what percentage of population got covid

SELECT Location, date, population, total_cases, (total_deaths/population)*100 as PercentPopulationInfected
FROM portfolio..Death
WHERE location LIKE 'Canada'
ORDER BY 1, 2


--Looking at counties with highest infection rate compared to population

SELECT Location, population, MAX (total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portfolio..Death
--WHERE location LIKE 'Canada'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing the counties with highest death count per population

SELECT Location, MAX (cast(total_deaths as int)) as TotalDeathCount
FROM portfolio..Death
--WHERE location LIKE 'Canada'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


--breaking down by continent
--Showing continants with highest death count per population

SELECT continent, MAX (cast(total_deaths as int)) as TotalDeathCount
FROM portfolio..Death
--WHERE location LIKE 'Canada'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers


SELECT SUM (new_cases) AS total_cases, SUM (new_deaths) AS total_deaths, SUM (new_deaths)/ SUM (new_cases)*100 as DeathPercentage
FROM portfolio..Death
--WHERE location LIKE 'Canada'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


--Looking at total popilation vs vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) AS RollingPeopleVaccinated
, (RollingPeopleVaccinated/population)*100
FROM portfolio..Death dea
JOIN Portfolio..Vaccination vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null-- AND new_vaccinations IS NOT NULL
ORDER BY 2, 3

--use CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolio..Death dea
JOIN Portfolio..Vaccination vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--Temp table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME,
population NUMERIC,
new_vaccination NUMERIC,
RollingPeopleVaccinated NUMERIC
)


INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolio..Death dea
JOIN Portfolio..Vaccination vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualizations

USE Portfolio
GO
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea. date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM portfolio..Death dea
JOIN Portfolio..Vaccination vac
	ON dea.location=vac.location
	AND dea.date=vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3


SELECT *
FROM PercentPopulationVaccinated