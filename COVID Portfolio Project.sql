select * from covid_vaccinations;
select * from covid_deaths;

select total_cases, total_deaths, (total_cases/total_deaths)*100
from covid_deaths 
drop table covid_vaccinations;
drop table covid_deaths;

-- select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from covid_deaths
order by 1,2

-- looking at total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from covid_deaths
order by 1,2

-- looking for India

select location, date, cast(total_cases as int) as totalcases, cast(total_deaths as int) as totaldeaths, (cast(total_deaths as int)/cast(total_cases as int))*100 as DeathPercentage
from covid_deaths
where location like '%india%'
order by 1,2
-- shows the likelihood of dying if contracted covid in India
-- total cases till 21 march 2024 is 4,50,36,197 estimate
-- total deaths till 21 march 2024 is 5,33,581 estimate

-- looking at total cases vs population for india
-- shows the percentage of population that got covid
select location, date, population, total_cases, (total_cases/population)*100 as CasePercentage 
from covid_deaths
where location like '%india%'
order by 1,2

-- looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as Percentagepopulationinfected 
from covid_deaths
-- where location like '%india%'
group by location, population
order by Percentagepopulationinfected desc

-- Showing countries with the highest death count per population

select location, max(CAST(total_deaths as int)) as TotalDeathCount
from covid_deaths
where continent <> ''
group by location
order by TotalDeathCount desc

-- by continent
select continent, max(CAST(total_deaths as int)) as TotalDeathCount
from covid_deaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- other then countries
select location, max(CAST(total_deaths as int)) as TotalDeathCount
from covid_deaths
where continent = ''
group by location
order by TotalDeathCount desc;
use portfolioprojects
 
 
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
from covid_deaths
where continent is not null
order by 1,2

select * from covid_vaccinations;
select * from covid_deaths;
use portfolioprojects
drop table covid_deaths;
drop table covid_vaccinations;

-- looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location, dea.date)
 --as RollingPeopleVaccinated, 
from covid_deaths dea join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
(sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location, dea.date))
--casting can also be done using (convert(decimal, vac.new_vaccinations))
as RollingPeopleVaccinated
from covid_deaths dea join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100 from PopvsVac

-- temp table

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
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
(sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location, dea.date)) --casting can also be done using (convert(decimal, vac.new_vaccinations))
as RollingPeopleVaccinated
from covid_deaths dea join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

--use portfolioprojects

select *,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
(sum(cast(vac.new_vaccinations as decimal)) over (partition by dea.location order by dea.location, dea.date))
as RollingPeopleVaccinated
from covid_deaths dea join covid_vaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


