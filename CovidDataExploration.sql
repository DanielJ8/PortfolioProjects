/*

Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


-- Viewing the 2 dataset imported
Select *
From CovidAnalysis..CovidDeaths
order by 3,4

Select *
From CovidAnalysis..CovidVaccinations
order by 3,4

-- Selecting data that will be used first
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidAnalysis..CovidDeaths
WHERE continent is not NULL AND continent != ''
ORDER BY location, date;

-- Total Cases vs Total Deaths
-- Shows chances of dying in Malaysia

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as RateOfDying
From CovidAnalysis..CovidDeaths
Where location like '%Malaysia%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows the percentage of population that are infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as InfectedPopulationPercentage
From CovidAnalysis..CovidDeaths
order by 1,2

-- Shows countries that has the Highest Infection Rate in comparison to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as InfectedPopulationPercentage
From CovidAnalysis..CovidDeaths
Group by Location, Population
order by InfectedPopulationPercentage desc

-- Shows Countries with the highest death count per population

SELECT location, population, MAX(total_deaths) as HighestDeathCount, MAX(total_deaths/population)*100 As PercentDeaths
FROM CovidAnalysis..CovidDeaths
WHERE continent is not NULL AND continent != ''
GROUP BY location, population
ORDER BY PercentDeaths DESC;

-- Shows contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- Global cases and death percentage
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths
where continent is not null 
order by 1,2

-- Join function to combine both dataset location and date
-- Total Population against Vaccinations
-- Shows Percentage of Population that has been vaccinated at least once

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 