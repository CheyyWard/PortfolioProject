

--Select *
--From PortfolioProject2.dbo.CovidVaccinations


Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject2.dbo.CovidDeaths
order by 1, 2


--Looking for Total Cases Vs Total Deaths

Select Location, date, total_cases, total_deaths,(CONVERT(FLOAT, total_deaths) / CONVERT(FLOAT, total_cases))*100 as DeathPercentage
From PortfolioProject2.dbo.CovidDeaths
where location like '%states%'
order by 1, 2

--Looking at Total Cases vs Total Population
--Shows percentage of population that has gotten covid

Select Location, date, total_cases, population,(CONVERT(FLOAT, total_cases) / CONVERT(FLOAT, population))*100 as DeathPercentage
From PortfolioProject2.dbo.CovidDeaths
where location like '%states%'
order by 1, 2

--Looking at countries with highest infection rate compared to population

Select Location, MAX(total_cases) as HighestInfectionCount, MAX((CONVERT(FLOAT, total_deaths) / CONVERT(FLOAT, total_cases)))*100 as PercentInfected
From PortfolioProject2.dbo.CovidDeaths
Group by location, population 
order by PercentInfected DESC

-- Showing Countries with the highest death count per population
Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject2.dbo.CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount DESC

--Looking a Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject2.dbo.CovidDeaths dea
Join PortfolioProject2.dbo.CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;

-- Terminate the previous statement with a semicolon
-- (If there is a previous statement)
;

-- Your CTE
WITH PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT 
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
    FROM 
        PortfolioProject2.dbo.CovidDeaths dea
    JOIN 
        PortfolioProject2.dbo.CovidVaccinations vac
    ON 
        dea.location = vac.location
        AND dea.date = vac.date
    WHERE 
        dea.continent IS NOT NULL
)


SELECT 
    *, 
    (RollingPeopleVaccinated / Population) * 100
FROM 
    PopvsVac;

	-- Creating view to store data for later visualizations
