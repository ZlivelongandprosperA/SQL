select *
from PortfolioProject..CovidDeaths
--where total_deaths is null
order by 3,4



--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4



-- Data which are going to be used
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2




----------------------------------------------------------------------------------------------------------------------------
-- EXPLARATORY ANALYSIS ----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------
-- Looking at Total Cases vs Total Deaths
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,1) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- US
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,1) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
and location like '%states%'
order by 1,2

-- Total cases vs Population (US)
select location, date, total_cases, population, round((total_cases/population)*100,7) as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
and location like '%states%'
order by 1,2

-- Total cases vs Population (PL)
select location, date, total_cases, population, round((total_cases/population)*100,7) as InfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
and location = 'Poland'
order by 1,2


-- Countries with highest infection rate compared to population
select location, population, max(total_cases) as HighestInfectionCount,  round((max(total_cases)/population)*100,1) as MaxInfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by MaxInfectedPercentage desc


select location, population, date, max(total_cases) as HighestInfectionCount,  round((max(total_cases)/population)*100,1) as MaxInfectedPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population, date
order by MaxInfectedPercentage desc


-- Countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc



-- Showing continents with higest death count

select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
and location not in ('International', 'World')
group by location
order by TotalDeathCount desc


select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, round(sum(cast(new_deaths as int))/sum(new_cases)*100, 1) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2


select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, round(sum(cast(new_deaths as int))/sum(new_cases)*100, 1) as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2



-- Looking at total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
											  order by dea.location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/dea.population)*100
from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
											  order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100 as VacToPop
from PopvsVac



-- TEMPORARY TABLE
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)




insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
											  order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *, (RollingPeopleVaccinated/population)*100 as VacToPop
from #PercentPopulationVaccinated



-- Create view to store data for later visualisations

Create view PercentPopulationVaccinated 
as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location 
											  order by dea.location, dea.date) as RollingPeopleVaccinated

from PortfolioProject..CovidDeaths dea 
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3



select * from PercentPopulationVaccinated