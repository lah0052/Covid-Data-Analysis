/*

Queries used for Tableau Project

*/

--Data for the Global Number table 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null 
--Group By date
order by 1,2
-----------------------------------------------------------------------------------------------------------------------------------------------

-- Data for the Infection Rate per Country
Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc
-----------------------------------------------------------------------------------------------------------------------------------------------

--Data for the Total Deaths per Continent
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population
order by PercentPopulationInfected desc
-----------------------------------------------------------------------------------------------------------------------------------------------

--Data for Infection Rate by Country
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
Group by Location, Population, date
order by PercentPopulationInfected desc












