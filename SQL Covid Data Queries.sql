SELECT* 
FROM Portfolio_Project..CovidDeaths
order by 3,4

--SELECT*
--FROM Portfolio_Project..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project..CovidDeaths
order by 1,2

--Looking at total cases verses total deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
Where location like '%states%'
order by 1,2

--Looking at Total Cases Vs Population
--Shows what percentage of the population got Covid


Select Location, date, population, total_cases, (total_cases/population)*100 as PercentofPopulationInfected
FROM Portfolio_Project..CovidDeaths
--Where location like '%states%'
order by 1,2


--Showing Highest Infection rates by country


Select Location, population, MAX (total_cases)  as HighestInfectionCount, MAX((total_cases/population))*100 as PercentofPopulationInfected
FROM Portfolio_Project..CovidDeaths
Group by location, population
--Where location like '%states%'
order by PercentofPopulationInfected desc

--Let's break this down by continent

Select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
FROM Portfolio_Project..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

--Global Numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_Project..CovidDeaths
Where continent is not null
order by 1,2

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations$ vac
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
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio_Project..CovidDeaths dea
Join Portfolio_Project..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
