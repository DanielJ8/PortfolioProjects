Select *
From CovidAnalysis..CovidDeaths
order by 3,4

--Select *
--From CovidAnalysis..CovidVaccinations
--order by 3,4

-- Select data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidAnalysis..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths
Where location like '%Malaysia%'
order by 1,2

--Looking at Total Cases vs Population
-- Shows what percentage of population get Covid
Select Location, date, total_cases, population, (total_cases/population)*100 as CovidPercentage
From CovidAnalysis..CovidDeaths
Where location like '%Malaysia%'
order by 1,2


-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as CovidPercentage
From CovidAnalysis..CovidDeaths
Group by Location, Population
order by CovidPercentage desc


-- Showing Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths
Where continent is not null
Group by Location 
order by TotalDeathCount desc

-- Let's break things down by continent

Select location, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount desc


-- Showing continents with the highest death count per population

Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing continents with the highest death count per population
Select continent, MAX(cast(Total_Deaths as int)) as TotalDeathCount
From CovidAnalysis..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS
-- Total cases, deaths and death percentage globally by date
Select  date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths
where continent is not null
Group by date
order by 1,2


-- Total cases, deaths and death percentage globally
Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
From CovidAnalysis..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM (CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,dea.date) as RollingPeopleVaccinated
From CovidAnalysis..CovidDeaths dea
Join CovidAnalysis..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

Select *
From PercentPopulationVaccinated