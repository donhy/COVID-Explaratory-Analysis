SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4; 

----SELECT *
----FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4; 

-- PREPARE THE DATA 
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs. Total Deaths 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE location like '%state%' AND continent is not null
ORDER BY 1,2;

-- Looking at Total Cases vs. Population
-- Show Percentage Of Population That Got Covid
SELECT location, date, total_cases, population, (total_cases/population) * 100 as PercetangeOfPopulatioInfected
FROM PortfolioProject..CovidDeaths$
WHERE location like '%state%'
ORDER BY 1,2;

-- Countries with Highest Infection Rate Compared to Population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)) * 100 as PercetangeOfPopulationInfected
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%state%'
GROUP BY location, population
ORDER BY PercetangeOfPopulationInfected DESC;

-- LET'S BREAK THINGS DONW BY CONTINENT
-- Showing Countries w/ Highest Death Count per Population
SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%state%'
WHERE continent is not null
Group by continent
ORDER BY TotalDeathCount Desc;


-- Showing Countries w/ Highest Death Count per Population
SELECT location, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%state%'
WHERE continent is not null
Group by location
ORDER BY TotalDeathCount Desc;

-- Showing Conteinets w/ Highest Death Count
SELECT continent, MAX(CAST(total_deaths as INT)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--WHERE location like '%state%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount Desc;


-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_Deaths, SUM(cast(new_deaths as int)) / sum(new_cases) * 100 as deathpercentage
from PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where DEA.continent is not null
order by 2,3 

-- Looking at Total Population vs Vaccinations
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where DEA.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
-- where DEA.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to Store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(BIGINT,vac.new_vaccinations)) OVER (PARTITION BY dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
where DEA.continent is not null
--order by 2,3 
