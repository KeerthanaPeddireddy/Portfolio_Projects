select * from portfolioproject..covid_deaths
order by 3,4

select Location, date, population, total_cases, new_cases, total_deaths
from portfolioproject..covid_deaths order by 1,2

-- total cases vs total deaths

select Location,date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_rate
from portfolioproject..covid_deaths 
where (date >='2022-01-01' and date <'2022-12-31') and location = 'India'
order by 1,2

-- OBSERVATION : above query explains what is the death rate in india in the year 2022 till today.


-- total cases vs population

select Location,date,population,total_cases, (total_cases/population)*100 as cases_rate
from portfolioproject..covid_deaths 
where location = 'India'
order by 1,2

-- OBSERVATION : above query explains what is the coivd cases rate in india from the start till today.

-- highest infection rate 
select Location,population, max(total_cases) as max_cases, max((total_cases/population))*100 as cases_rate
from portfolioproject..covid_deaths 
-- where location = 'India'
group by population,location
order by cases_rate desc

-- 4
select Location,population,date, max(total_cases) as max_cases, max((total_cases/population))*100 as cases_rate
from portfolioproject..covid_deaths 
-- where location = 'India'
group by population,location,date
order by cases_rate desc

-- Countries with highest death count per population
select Location,max(cast(total_deaths as int)) as max_deathcases
from portfolioproject..covid_deaths 
-- where location = 'World'
where continent is not null and location is not null
group by location
order by max_deathcases desc

--using continent 
select continent,max(cast(total_deaths as int)) as max_deathcases
from portfolioproject..covid_deaths 
-- where location = 'World'
where continent is not null 
group by continent
order by max_deathcases desc

-- total new daths vs new cases filtered by date

select date,sum(cast(new_deaths as int)) as sum_deathcases, sum(new_cases) as total_newcases, (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathrate
from portfolioproject..covid_deaths 
-- where location = 'World'
where continent is not null 
group by date
order by 1,2
-- order by max_deathcases desc

select sum(cast(new_deaths as int)) as sum_deathcases, sum(new_cases) as total_newcases, (sum(cast(new_deaths as int))/sum(new_cases))*100 as deathrate
from portfolioproject..covid_deaths 
-- where location = 'World'
where continent is not null 
-- group by date
order by 1,2

--2
select location,sum(cast(new_deaths as int)) as totaldeathcount
from portfolioproject..covid_deaths 
-- where location = 'World'
where continent is null 
and location not in ('World','International','European Union','High income','Upper middle income','Lower middle income','Low income')
group by location 
-- group by date
order by totaldeathcount desc

-- join both tables

select * from portfolioproject..covid_deaths as cd join portfolioproject..CovidVaccinations as cv on cd.location = cv.location
-- Total population vs vaccination

select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as totalvaccs_country,
-- (totalvaccs_country/cd.population)*100 as vacc_pc
from portfolioproject..covid_deaths cd join portfolioproject..CovidVaccinations cv 
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null 
-- and cd.location = 'India'
-- and cv.new_vaccinations is not null
-- group by cd.location,cv.location
order by 2,3

-- using cte

with popvsvac (continent,locations,date,population,new_vaccinations,totalvaccs_country)
as 
(
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as totalvaccs_country
-- (totalvaccs_country/cd.population)*100 as vacc_pc
from portfolioproject..covid_deaths cd join portfolioproject..CovidVaccinations cv 
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null 
-- and cd.location = 'India'
-- and cv.new_vaccinations is not null
-- group by cd.location,cv.location
)

select *,(totalvaccs_country/population)*100 as vacc_pc from popvsvac

-- uisng temp table 

drop table if exists #populationvsvaccinations 
create table #populationvsvaccinations 
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
totalvaccs_country numeric
)
insert into #populationvsvaccinations 
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as totalvaccs_country
-- (totalvaccs_country/cd.population)*100 as vacc_pc
from portfolioproject..covid_deaths cd join portfolioproject..CovidVaccinations cv 
on cd.location = cv.location 
and cd.date = cv.date
-- where cd.continent is not null 
-- and cd.location = 'India'
-- and cv.new_vaccinations is not null
-- group by cd.location,cv.location

select *,(totalvaccs_country/population)*100 as vacc_pc
from #populationvsvaccinations 


-- creating view for later 
USE portfolioproject
GO
create view populationvaccinations as
select cd.continent, cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(cast(cv.new_vaccinations as bigint)) over (partition by cd.location order by cd.location,cd.date) as totalvaccs_country
-- (totalvaccs_country/cd.population)*100 as vacc_pc
from portfolioproject..covid_deaths cd join portfolioproject..CovidVaccinations cv 
on cd.location = cv.location 
and cd.date = cv.date
where cd.continent is not null 
-- and cd.location = 'India'
-- and cv.new_vaccinations is not null
-- group by cd.location,cv.location

select * from populationvaccinations