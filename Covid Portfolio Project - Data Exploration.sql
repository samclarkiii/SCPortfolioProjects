

select * from PortfolioProject..CovidDeaths
where continent is NOT null
order by 3,4

--select * from PortfolioProject..CovidVaccinations
--order by 3,4

--Select starting Data

Select location,date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

Select location,date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
Where location like '%States%'
order by 1,2

-- Looking at Total Cases vs Population
-- Shows what % of population got covid

Select location,date, population, total_cases, (total_cases/population) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
Where location like '%States%'
order by 1,2


-- Looking at Countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount , max((total_cases/population)) * 100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--Where location like '%States%'
Group by location,population
order by PercentagePopulationInfected desc

-- Showing Countries with highest deathcount per population

Select location, population, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%States%'
where continent is not null
Group by location,population
order by TotalDeathCount desc

-- CONTINENT BREAKDOWN	
-- Showing continents with the highest death count per population

--Select location, max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
----Where location like '%States%'
--where continent is null
--Group by location
--order by TotalDeathCount desc

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--Where location like '%States%'
where continent is NOT null
Group by continent
order by TotalDeathCount desc


-- Global numbers

Select date, sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%States%'
where continent is not null
group by date
order by 1,2

-- Looking at total population vs Vaccinations
-- % of Pop that has recieved at least one covid vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated,

from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Using CTE to perform calculation on partition by in previous query

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 from PopvsVac

-- Using Temp Table to perform calculation on partition by in previous query

Drop table if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(convert(bigint, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidVaccinations vac
join PortfolioProject..CovidDeaths dea
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select * from PercentPopulationVaccinated