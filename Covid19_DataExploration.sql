select * 
from PortfolioProject..CovidDeaths
where continent != ''
order by 3,4

--select data we are going to be using
select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
where continent != ''
order by 1,2

select location, date, total_cases, new_cases, total_deaths, population 
from CovidDeaths
where continent != ''
order by 1,2

--looking at total cases vs total deaths
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from covidDeaths
where continent != ''
order by 1,2


--shows the likelihood of dying you have contracted covid in india
Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from covidDeaths
where continent != '' and location like '%india%'
order by 1,2

--looking at total cases vs population
Select location, date, total_cases,population, 
(CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentagePopulationInfected
from covidDeaths
where  continent != '' and location like '%india%'
order by 1,2

--looking at countries with highest infection rate with population
Select location, max(total_cases) as HighestInfectionCount, population, 
max((CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))) * 100 AS PercentagePopulationInfected
from covidDeaths
where continent != ''
group by location, population
order by PercentagePopulationInfected desc;

--showing countries with the highest
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent != ''
group by location
order by TotalDeathCount desc;

--group by continents
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent != ''
group by continent
order by TotalDeathCount desc;

--GLOBAL NUMBERS
select sum(cast(new_cases as float)) as total_cases, sum(cast(new_deaths as float)) as total_deaths, (sum(cast(new_deaths as float)) / NULLIF(sum(cast(new_cases as float)),0)) * 100 AS Deathpercentage
from CovidDeaths
where continent != ''
--group by  date
order by 1,2
 
 --looking at total vaccinations vs total population
 with popVsvac as(select dea.population as population, 
 dea.date as date, 
 dea.continent as continent, 
 dea.location as location, 
 vac.new_vaccinations as vaccinations, 
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent !=''
)

 select *, (RollingPeopleVaccinated/nullif(cast(population as int),0)) * 100
 from popVsvac

 --TEMP TABLE
 drop table if exists #PercentagePopulatedVaccinated
 create table #PercentagePopulatedVaccinated(
 Continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingpeopleVaccinated numeric
 )
insert into #PercentagePopulatedVaccinated
select dea.continent, 
 dea.location, 
convert(datetime,dea.date),
dea.population,
 vac.new_vaccinations as vaccinations, 
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent !=''

 select *, (RollingPeopleVaccinated/nullif(population,0)) * 100
 from #PercentagePopulatedVaccinated

 --creating view
 create view PercentagePopulationVaccinated as
 select dea.continent, 
 dea.location, 
convert(datetime,dea.date) as date,
dea.population,
 vac.new_vaccinations as vaccinations, 
 sum(cast(vac.new_vaccinations as int)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
 from CovidDeaths dea
 join CovidVaccinations vac
 on dea.location = vac.location
 and dea.date = vac.date
 where dea.continent !=''

 select * from
 PercentagePopulationVaccinated
