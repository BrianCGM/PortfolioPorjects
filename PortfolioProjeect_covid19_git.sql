SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are goiung to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths
order by 1,2

-- Looking at total cases vs Total Deaths
-- Shows the likeelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%Canada%'
order by 1,2

-- Looking at Total Cases Vs Population
-- Shows what Percentage of population got covid

SELECT location, date, Population, total_cases, (total_deaths/Population)*100 AS DeathPercentage
FROM dbo.CovidDeaths
WHERE location like '%Canada%'
order by 1,2 DESC

-- What countries have the highest infection rates

SELECT location, Population, MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/Population))*100 AS PercenteOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Canada%'
GROUP BY location,population
order by PercenteOfPopulationInfected DESC

-- What countries have the highest Death count per population


SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Canada%'
WHERE continent IS NULL
GROUP BY location
order by TotalDeathCount DESC

-- LETS'S BREAK THINGS DOWN BY CONTINENT 

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Canada%'
WHERE continent IS NOT NULL
GROUP BY continent
order by TotalDeathCount DESC

-- Showing the Continents with the highest death counts per population

SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Canada%'
WHERE continent IS NOT NULL
GROUP BY continent
order by TotalDeathCount DESC


--Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS INT))/SUM(New_Cases) * 100 AS DeathPercentage
FROM dbo.CovidDeaths
--Where location LIKE '%Canada%'
WHERE Continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 DESC


-- LOOKing at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM dbo.CovidDeaths  AS dea
JOIN dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Need to do sum of new vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location,
dea.Date) AS RollingPeopleVaccinated,
(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths  AS dea
JOIN dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE -- Temp Table

WITH PopvsVac (Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location,
dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths  AS dea
JOIN dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population) *100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vacination numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location,
dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths  AS dea
JOIN dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population) *100
FROM #PercentPopulationVaccinated


--CREATE View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER BY dea.Location,
dea.Date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM dbo.CovidDeaths  AS dea
JOIN dbo.CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated