-- location contains World, continent & income level data
Select * from dbo.death
where continent is not null
order by 3,4


--select data the we going to use 
select location, date, new_cases, total_cases, total_deaths, population
from dbo.death
order by 1,2 


-- Looking at total cases vs total deaths (by country)
-- shows likehood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Death_Percentage 
from dbo.death
order by 2,5 

-- Looking at total cases vs total death (United States) 
-- shows likehood of dying if you contract covid in your country 
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Death_Percentage 
from dbo.Death$
where location like '%state%'
order by 2,5 


-- Looking at total cases vs population 
-- shwos what percentage of population got covid 
select location, date, total_cases, population, round((total_cases/population)*100,5) as Cases_Percentage 
from dbo.Death$
order by 1,2 

-- Looking at total cases vs population (United States) 
-- shwos what percentage of population got covid 
select location, date, total_cases, population, round((total_cases/population)*100,5) as Cases_Percentage 
from dbo.death
where location like '%state%'
order by 1,2 


--Looking at countries with highest infrection rate compared to population 
select location, population, max(total_cases) as Highest_Infection_Count, max((total_cases/population))*100 as Percentage_Population_Infected 
from dbo.death
group by location, population 
order by 4 desc 



-- Showing countries with highest death count per population 
select location, max(cast(total_deaths as int)) as Total_Death_Count
from dbo.death
where continent is not null
group by location
order by Total_Death_Count desc 



-- Break things down by continent 
-- Showing continent with highest death count per population 
select continent, max(cast(total_deaths as int)) as Total_Death_Count
from dbo.death
where continent is not null
group by continent
order by Total_Death_Count desc 

-- Break things down by location
select location, max(cast(total_deaths as int)) as Total_Death_Count
from dbo.death
where continent is null
group by location
order by Total_Death_Count desc 



-- Show Global Number of New Cases & New Death 
select date, 
sum(new_cases) as Total_New_Cases, 
sum(cast(new_deaths as int)) as Total_New_Death, 
round(sum(cast(new_deaths as int))/sum(total_cases)*100,2) as Death_Percentage
from dbo.death
where continent is not null
group by date
order by date

-- Show Global Number of New Cases & New Death (WITHOUT DATE) 
select --date, 
sum(new_cases) as Total_New_Cases, 
sum(cast(new_deaths as int)) as Total_New_Death, 
round(sum(cast(new_deaths as int))/sum(new_cases)*100,2) as Death_Percentage
from dbo.death
where continent is not null
--group by date
--order by date




-----------------------------------------------------------------------------------------------
-- Covid Vaccincation Data
select * from dbo.vaccination
order by 3,4


--Join Death tabel & Vaccination tabel 
Select * 
from dbo.death dea
Join dbo.vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date 



-- Looking at Total Population vs Vaccination
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from dbo.death dea
Join dbo.vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 1,2,3


----------- Looking at New Vaccinatino by Location ----------
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (Partition by dea.location order by dea.location, dea.date)
from dbo.death dea
Join dbo.vaccination vac
	on dea.location = vac.location
	and dea.date = vac.date 
where dea.continent is not null
order by 2,3


----------------------------------------------------------------------------------------------------
--Create View for visualization

Create view TotalCasesVSTotalDeathsbyCountrires as
select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100,2) as Death_Percentage 
from dbo.death
where continent is not null



select * from
TotalCasesVSTotalDeathsbyCountrires