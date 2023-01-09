select location,date,total_cases,new_cases,total_deaths,population
from CovidDeath
order by 1,2

--looking at total cases vs total death

select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
from CovidDeath
where location = 'India'
order by 1,2

--looking at total cases vs population

select location,date,total_cases,population, (total_cases/population)*100 as PopulationAffected 
from CovidDeath
where location = 'India'
order by 1,2

select location,date,total_cases,population, (total_cases/population)*100 as PopulationAffected 
from CovidDeath
order by 1,2

--Countries with highest infection rate

select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationAffected 
from CovidDeath
group by location,population
order by HighestInfectionCount desc

--Countries with highest death w.r.t population 

select location,max(cast(total_deaths as int)) as TotalDeaths,population
from CovidDeath
where continent is not null
Group by location,population
order by TotalDeaths desc


-- Continent wise breadown of covid affected deaths(below query helps in case of bad data)

select location,max(cast(total_deaths as int)) as TotalDeaths
from CovidDeath
where continent is null
Group by location
order by TotalDeaths desc

-- query for better drill down effect in tableau 

select continent,max(cast(total_deaths as int)) as TotalDeaths
from CovidDeath
where continent is null
Group by continent
order by TotalDeaths desc

-- Global numbers 

--country wise

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercentage
from CovidDeath
where continent is not null
group by date
order by 1,2

-- total global number

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeath,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as Deathpercentage
from CovidDeath

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeath dea join CovidVaccination vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--looking at total population and people vaccinated

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeath dea join CovidVaccination vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--% people vaccinated using cte

with popvsvac(Continent, Location, Date, Population,New_Vaccination, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from CovidDeath dea join CovidVaccination vac
on dea.location=vac.location
and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated from popvsvac


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
order by 2,3


--view to store data for visualization

create view PercentagePeopleVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeath dea
Join CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * from PercentagePeopleVaccinated