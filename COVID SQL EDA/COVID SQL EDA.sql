SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4

-- Select data that we are going to be using
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract COVID in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1, 2

-- Looking at the Total Cases vs Population
-- Shows what percentage of population got COVID
SELECT Location, date, population, total_cases, (total_cases / population) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE Location LIKE '%states%'
ORDER BY 1, 2

-- Looking at countries with the highest infection rate compared to population
SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, 
		MAX((total_cases / population)) * 100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY Location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with the Highest Death Count per Population
SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- Breaking things down by continent
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing continents with the highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global numbers
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
		SUM(CAST(new_deaths AS int)) / SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2



-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3


-- Use CTE
-- Number of columns in CTE must match number of columns in SELECT statement
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3
)
SELECT *, (RollingPeopleVaccinated / population) * 100
FROM PopvsVac


-- Temp table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *, (RollingPeopleVaccinated / population) * 100
FROM #PercentPopulationVaccinated



-- Creating view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) 
		OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2, 3

SELECT *
FROM PercentPopulationVaccinated