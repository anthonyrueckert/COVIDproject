select *
from portfolio..CovidDeaths
where continent is not null
order by 3,4

/*Selecting Data to be used*/
select location,date,total_cases,new_cases,total_deaths,population
from portfolio..CovidDeaths
where continent is not null
order by 1,2

/*Mortality Rate*/
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as 'mortality rate'
from portfolio..CovidDeaths
where continent is not null
order by 1,2

/*Infection Rate (Total Cases/Population)*/
select location,date,total_cases,total_deaths, (total_cases/population)*100 as 'infection rate'
from portfolio..CovidDeaths
where continent is not null

/*Highest infection rate per capita*/
select location,population,max(total_cases) as 'highest infection count', max((total_cases/population)*100) as 'infection rate'
from portfolio..CovidDeaths
where continent is not null
group by location, population
order by 'infection rate' desc

/*Highest death count per capita*/
select location,max(cast(total_deaths as int)) as total_death_count
from portfolio..CovidDeaths
where continent is not null
group by location
order by total_death_count desc

/*Continental data*/
/*Highest Death count*/
select location,max(cast(total_deaths as int)) as total_death_count
from portfolio..CovidDeaths
where continent is null
group by location
order by total_death_count desc

select continent,max(cast(total_deaths as int)) as total_death_count
from portfolio..CovidDeaths
where continent is not null
group by continent
order by total_death_count desc

/*Global data*/
select sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from portfolio..CovidDeaths
where continent is not null
order by 1,2


/*Vaccination Data*/
/*Population vs Vaccinations*/
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cumulativeVaccinations
from portfolio..CovidDeaths as dea
join portfolio..CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null and dea.continent != 'NULL'
order by 2,3

/*Percentage of population that is vaccinated by date*/
with popvsvac (continent,location,date,population, new_vaccinations, cumulativeVaccinations)
as
(
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cumulativeVaccinations
from portfolio..CovidDeaths as dea
join portfolio..CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
	where dea.continent is not null and dea.continent != 'NULL'
)
select *, (cumulativeVaccinations/population)*100
from popvsvac

/*Doing the same thing as above but with a temp table*/
drop table if exists #percentvaccinated
create table #percentvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cumulativeVaccinated numeric
)

insert into #percentvaccinated 
select dea.continent, dea.location, dea.date, population, cast(vac.new_vaccinations as int),
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cumulativeVaccinations
from portfolio..CovidDeaths as dea
join portfolio..CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.continent != 'NULL'

select *, (cumulativeVaccinated/population)*100
from #percentvaccinated


/*creates a new table essentially*/
/*Creating views to visualize later*/
create view percentvaccinated as
select dea.continent, dea.location, dea.date, population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as cumulativeVaccinations
from portfolio..CovidDeaths as dea
join portfolio..CovidVaccinations as vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null and dea.continent != 'NULL'
