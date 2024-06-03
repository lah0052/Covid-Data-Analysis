SELECT * 
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccinations$
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

--total deaths vs total cases (death_rate) in united states
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_rate
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2

--total cases vs population (infection_rate) in united states
SELECT Location, date, population, total_cases, (total_cases/population)*100 AS infection_rate
FROM PortfolioProject..CovidDeaths$
WHERE location LIKE '%states%'
ORDER BY 1,2

--countries with highest infection rate
SELECT Location, population, MAX(total_cases) AS highest_num_cases, MAX((total_cases/population))*100 AS infection_rate
FROM PortfolioProject..CovidDeaths$
GROUP BY location,population
ORDER BY infection_rate desc

--countries with the highest total death count
SELECT Location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count desc

--continents with the highest total death count (might need to change) to commented out version
SELECT Location, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NULL AND location <> 'World' AND location <> 'European Union' 
GROUP BY location
ORDER BY total_death_count desc

SELECT continent, MAX(cast(total_deaths as int)) AS total_death_count
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count desc

--global  totals 
SELECT  SUM(new_cases) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_rate
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--global daily totals
SELECT  date, SUM(new_cases) AS total_cases,SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_rate
FROM PortfolioProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--gets total vac numbers by summing new_vaccinations and seperates them by location and date.
--joins the tables based off  location and date
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CONVERT(int , vac.new_vaccinations )) OVER (PARTITION by dea.location Order by dea.location, dea.date) AS total_vaccinations
FROM PortfolioProject..CovidDeaths$ AS dea
JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--total vaccinations vs total population (vac_percentage) done using a CTE 
WITH PopvsVac(continent, location, date, population, new_vaccinations, total_vaccinations) AS
(
	SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
		SUM(CONVERT(int , vac.new_vaccinations )) OVER (PARTITION by dea.location Order by dea.location, dea.date) AS total_vaccinations
	FROM PortfolioProject..CovidDeaths$ AS dea
	JOIN PortfolioProject..CovidVaccinations$ AS vac
		ON dea.location = vac.location 
		AND dea.date = vac.date
	WHERE dea.continent IS NOT NULL
)
Select*, (total_vaccinations/population)*100 AS vac_percentage
FROM PopvsVac

--temp table
Create Table #PercentPopulationVaccinated
(
	continent nvarchar(255), 
	location nvarchar(255), 
	date DATETIME, 
	population NUMERIC, 
	new_vaccinations NUMERIC,
	total_vaccinations NUMERIC
)
INSERT into #PercentPopulationVaccinated
	SELECT dea.continent,
	dea.location,	
	dea.date,
	dea.population,
	vac.new_vaccinations,
	(SUM(CONVERT(int , vac.new_vaccinations )) OVER (PARTITION by dea.location Order by dea.location, dea.date)) AS total_vaccinations
FROM PortfolioProject..CovidDeaths$ AS dea
JOIN PortfolioProject..CovidVaccinations$ AS vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

Select*, (total_vaccinations/population)*100 AS percent_vaccinated
FROM #PercentPopulationVaccinated

--create view to store data for later visualizations
CREATE VIEW PercentPopulationVaccinatedView AS
SELECT dea.continent,
    dea.location,    
    dea.date,
    dea.population,
    vac.new_vaccinations,
    (SUM(CONVERT(int , vac.new_vaccinations )) OVER (PARTITION by dea.location Order by dea.location, dea.date)) AS total_vaccinations
FROM PortfolioProject..CovidDeaths$ AS dea
JOIN PortfolioProject..CovidVaccinations$ AS vac
    ON dea.location = vac.location 
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM PercentPopulationVaccinatedView;
