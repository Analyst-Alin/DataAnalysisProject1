


--                                             COVID DEATHS FILE

select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to be using
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- LOOKING AT TOTAL CASES Vs TOTAL DEATHS

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Shows the likelihood of dying if you contract covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'india'
and continent is not null
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like 'Canada'
and continent is not null
order by 1,2

-- LOOKING AT TOTAL CASES Vs POPULATION

--Shows what Percentage of Population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
where location like 'Canada'
and continent is not null
order by 1,2

select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like 'Canada'
where continent is not null
order by 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like 'Canada'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like 'Canada'
where continent is not null
Group by location
order by TotalDeathCount desc


-- BREAK DOWN BASED ON CONTINENTS

--select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
---- where location like 'Canada'
--where continent is null
--Group by location
--order by TotalDeathCount desc

-- Showing Continents with the Highest Death Count per Population
select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
-- where location like 'Canada'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- BREAKING DOWN BASED ON GLOBAL NUMBERS

-- Based on Date, the Cases and Deaths and their percentage
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
Group by date
order by 1,2

-- Entire Cases and Deaths and their Percentage
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--Group by date
order by 1,2



--                                             COVID VACCINATIONS FILE

select *
from PortfolioProject..CovidVaccinations

-- JOINING THE TWO TABLES - CovidDeaths and CovidVaccinations

select * 
from PortfolioProject..CovidDeaths dea
join 
PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date

-- LOOKING AT TOTAL POPULATION Vs VACCINATIONS (Total people in the world that has been vaccinated)

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join 
PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Rolling Count - adding consecutive new_vaccinations values 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated -- If cast is used here, it shows arithmetic overflow
from PortfolioProject..CovidDeaths dea
join 
PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Population Vs Vacinnation
--select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated -- If cast is used here, it shows arithmetic overflow
--, (RollingPeopleVaccinated/population)*100
--from PortfolioProject..CovidDeaths dea
--join 
--PortfolioProject..CovidVaccinations vac
--	on dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3


-- USE CTE

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) -- no of columns in cte should be equal to no of columns in select
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated -- If cast is used here, it shows arithmetic overflow
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join 
PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac
order by 2,3



-- USE TEMP TABLE

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated -- If cast is used here, it shows arithmetic overflow
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join 
PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated


-- Creating View to store data for later VISUALIZATIONS

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated -- If cast is used here, it shows arithmetic overflow
--, (RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
join 
PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated