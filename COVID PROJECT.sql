select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$
order by 1,2

-- total cases vs total deaths

select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as deathpercentage 
from CovidDeaths$
where location like '%states%'
order by 1,2

--total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as percentagepopulationinfected 
from CovidDeaths$
where location like '%states%'
order by 1,2


select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentagepopulationinfected 
from CovidDeaths$
--where location like '%states%'
group by location,population
order by percentagepopulationinfected desc

select location, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
order by totaldeathcount desc


-- global numbers

select date, sum(new_cases), sum(cast(new_deaths as int)), sum(new_cases)/sum(cast(new_deaths as int))*100 as deathpercentage
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by date
order by 1,2
--looking at the total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

---use cte
with PopvsVac (continent, location, date, population, new_vaccinations, rollingpplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpplevaccinated/population)*100
from PopvsVac

---temp table
drop table if exists #percentpoppulationvaccinated
create table #percentpoppulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
 rollingpplevaccinated numeric
 )


insert into  #percentpoppulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpplevaccinated/population)*100
from #percentpoppulationvaccinated



----creating view to store for later visualizations

Create view percentpoppulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as rollingpplevaccinated
from CovidDeaths$ dea
join CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Create view populationinfected as
select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population))*100 as percentagepopulationinfected 
from CovidDeaths$
where location like '%states%'
group by location,population
--order by percentagepopulationinfected desc

Create View deathcount as
select location, max(cast(total_deaths as int)) as totaldeathcount
from CovidDeaths$
--where location like '%states%'
where continent is not null
group by location
--order by totaldeathcount desc
