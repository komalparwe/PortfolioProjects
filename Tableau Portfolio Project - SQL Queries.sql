/*
Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'high income', 'Lower middle income', 'low income')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc






/*old Queries in case you want to refer


select * from CovidDeaths where continent is not null


select location, date, total_cases, new_cases, total_deaths, population from CovidDeaths
where continent is not null
order by 1,2


---looking at total cases vs total deaths
--- show likelihood of dying if you get covid in your country
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage from CovidDeaths
where location = 'Canada' 


----looking at total cases vs population
---Shows what percentage of population got covid
select location, date, total_cases, total_deaths, population, (total_cases/population)*100 as PopulationInfectionpercentage from CovidDeaths
where location = 'Canada' 


---looking at countries with highest infection rate compared to population
select location, population, MAX( total_cases) as HighestInfectionCount,  MAX( (total_cases/population))*100 as PopulationInfectionpercentage from CovidDeaths
where continent is not null
group by Location, population
order by PopulationInfectionpercentage  desc



---looking at countries with highest death count per population
select location, MAX(cast( total_deaths as int)) as TotalDeathCount from CovidDeaths
where continent is not null
group by Location, population
order by TotalDeathCount  desc

---Now look at data by continent
select location, MAX(cast( total_deaths as int)) as TotalDeathCount from CovidDeaths
where continent is  null and location not like '%income%'
group by location
order by TotalDeathCount  desc

---Showing continents with highest DeathCount
select continent, MAX(cast( total_deaths as int)) as TotalDeathCount from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount  desc


---Global numbers
select  date,Sum(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths , SUM(cast(new_deaths as int))/Sum(new_cases)*100 as deathpercentage from CovidDeaths
where continent is not null
group by date
order by 1,2

---Looking at Total population Vs Vaccinations
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
,SUM(CAST(cv.new_vaccinations as int)) OVER (Partition by cd.Location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths as cd 
inner join  CovidVaccinations as cv on
 cd.location = cv.location and cd.date=cv.date
 where cd.continent is not null
 order by 2,3


 ---USE CTE
 with PopVsVac(continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
 as
 (
 select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
,SUM(CAST(cv.new_vaccinations as bigint)) OVER (Partition by cd.Location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths as cd 
inner join  CovidVaccinations as cv on
 cd.location = cv.location and cd.date=cv.date
 where cd.continent is not null
 --order by 2,3
 )

 select *, (RollingPeopleVaccinated/population) * 100 as RollingPeopleVaccinatedPercentage from PopVsVac

 
 ---USE TEMP TABLE
 Drop table if exists #PercentPopVaccinated
 create table #PercentPopVaccinated
 (continent nvarchar(50), 
 location nvarchar(50), 
 date datetime, 
 population numeric, 
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

 Insert into #PercentPopVaccinated
 select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
,SUM(CAST(cv.new_vaccinations as bigint)) OVER (Partition by cd.Location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths as cd 
inner join  CovidVaccinations as cv on
 cd.location = cv.location and cd.date=cv.date
 --where cd.continent is not null
 --order by 2,3


  select *, (RollingPeopleVaccinated/population) * 100 as RollingPeopleVaccinatedPercentage from #PercentPopVaccinated



  ----Creating view to store data for later visualisations
 Create view PercentPopVaccinated as
   select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
,SUM(CAST(cv.new_vaccinations as bigint)) OVER (Partition by cd.Location order by cd.location, cd.date) as RollingPeopleVaccinated
from CovidDeaths as cd 
inner join  CovidVaccinations as cv on
 cd.location = cv.location and cd.date=cv.date
 where cd.continent is not null
 --order by 2,3


 /*