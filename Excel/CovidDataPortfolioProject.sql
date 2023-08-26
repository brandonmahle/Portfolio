Select *
From PortfolioProject..[covid-deaths]
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..[covid-vaccinations]
--order by 3,4

-- Select Data that we are going to be using


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject.dbo.[covid-deaths]
Where continent is not null
order by 1,2

--Fixing the column data types
ALTER TABLE "covid-deaths"
ALTER COLUMN "total_cases" float;

ALTER TABLE "covid-deaths"	
ALTER COLUMN "total_deaths" float;


-- OR you can do this 
-- cast(total_deaths as int)


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
From PortfolioProject.dbo.[covid-deaths]
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject.dbo.[covid-deaths]
Where location like '%states%' AND continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

Select Location, date, population, total_cases, (total_cases/population)*100 asPercentInfected
From PortfolioProject.dbo.[covid-deaths]
Where location = 'United States' AND continent is not null
order by 1,2



-- Looking at countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, (Max(total_cases)/population)*100 as PercentInfected
From PortfolioProject.dbo.[covid-deaths]
--Where location = 'United States'
Where continent is not null
Group by location, population
order by PercentInfected desc



-- Showing countries with Highest Death Count per Population

Select Location, population, MAX(total_deaths) as TotalDeathCount, (Max(total_deaths)/population)*100 as DeathPercentage
From PortfolioProject.dbo.[covid-deaths]
--Where location = 'United States'
Where continent is not null
Group by location, population
order by TotalDeathCount desc




-- Breaking things down by location

Select location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.[covid-deaths]
--Where location = 'United States'
Where continent is null
Group by location
order by TotalDeathCount desc


-- Showing the continents with the highest death per population

Select continent, MAX(total_deaths) as TotalDeathCount
From PortfolioProject.dbo.[covid-deaths]
--Where location = 'United States'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers, excluding null values

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths,
SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject.dbo.[covid-deaths]
--Where location = 'United States' 
Where continent is not null AND new_cases is not null AND new_cases != 0
group by date
order by 1,2


--Fixing the column data types

ALTER TABLE "covid-vaccinations"	
ALTER COLUMN "new_vaccinations_smoothed" float;

-- Looking at Total Populations vs Vaccinations 
-- Combining both tables

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed,
SUM(vac.new_vaccinations_smoothed) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PortfolioProject.dbo.[covid-deaths] dea
Join PortfolioProject.dbo.[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations_smoothed, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed,
SUM(new_vaccinations_smoothed) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PortfolioProject.dbo.[covid-deaths] dea
Join PortfolioProject.dbo.[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3
)

Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations_smoothed numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed,
SUM(vac.new_vaccinations_smoothed) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PortfolioProject.dbo.[covid-deaths] dea
Join PortfolioProject.dbo.[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visulizations


Create View HighestDeathRateByCountry as
Select Location, population, MAX(total_deaths) as TotalDeathCount, (Max(total_deaths)/population)*100 as DeathPercentage
From PortfolioProject.dbo.[covid-deaths]
Where continent is not null
Group by location, population


Create View PercentPopulatedVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed,
SUM(vac.new_vaccinations_smoothed) OVER (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PortfolioProject.dbo.[covid-deaths] dea
Join PortfolioProject.dbo.[covid-vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Create View HighestDeathsByCountry as
Select Location, population, MAX(total_deaths) as TotalDeathCount, (Max(total_deaths)/population)*100 as DeathPercentage
From PortfolioProject.dbo.[covid-deaths]
--Where location = 'United States'
Where continent is not null
Group by location, population
