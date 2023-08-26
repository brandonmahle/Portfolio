-- 1.

-- Exported this to Excel as "Tableau-Table-1
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths,
SUM(cast(new_deaths as bigint))/SUM(new_cases)*100 as DeathPercentage 
From PortfolioProject.dbo.[covid-deaths]
--Where location = 'United States' 
Where continent is not null 
order by 1,2

-- 2.

-- Exported this to Excel as "Tableau-Table-2

Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProject.dbo.[covid-deaths]
Where continent is null
and location not in ('World','European Union',
'International', 'High Income','Upper middle income',
'lower middle income', 'Low income')
Group by location
order by TotalDeathCount desc


--3. 

-- Exported this to Excel as "Tableau-Table-3


Select Location, population, MAX(total_cases) as HighestInfectionCount, (Max(total_cases)/population)*100 as PercentInfected
From PortfolioProject.dbo.[covid-deaths]
--Where location = 'United States'
Where continent is not null
Group by location, population
order by PercentInfected desc



 -- 4.


 Select Location, population, date, MAX(total_cases) as HighestInfectionCount,
 (Max(total_cases)/population)*100 as PercentInfected
From PortfolioProject.dbo.[covid-deaths]
--Where location = 'United States'
Where continent is not null
Group by location, population, date
order by PercentInfected desc