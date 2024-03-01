/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


--Select Data we are using
Select location ,date, total_cases,new_cases,total_deaths,population
from Covid_Deaths 
where continent is not null
order by 1,2 

--Analysis of Total Cases  vs Total Deaths
--Likelyhood of dying if you contract covid in Zimbabwe

Select location ,date, total_cases,total_deaths , (cast (total_deaths as float )/ total_cases )* 100 as Death_Percentage 
from Covid_Deaths 
where location like '%Zimbabwe%'
order by 1,2 

--Looking at total cases  vs population 
--Shows what percentage of poplation got Covid

Select location ,date,population, total_cases, (cast (total_cases as float )/ population )* 100 as PercentPopulationInfected
from Covid_Deaths 
--where location like '%Zimbabwe%'
order by 1,2 


--countries with highest infection rate compared to Population 
Select location ,population, ROUND(MAX((CAST(total_cases AS FLOAT) / population)) * 100, 2) AS PercentPopulationInfected
from Covid_Deaths 
--where location like '%Zimbabwe%'
group by location ,population
order by PercentPopulationInfected desc

--Showing Countries with Highest Death Count per Population
Select location ,MAX(cast(total_deaths as int )) as TotalDeathCount
from Covid_Deaths 
--where location like '%Zimbabwe%'
where continent is not null
group by location 
order by TotalDeathCount desc

--	BREAKING DOWN BY CONTINENT 

--Showing Countries with Highest Death Count per Population
Select continent ,MAX(cast(total_deaths as int )) as TotalDeathCount
from Covid_Deaths 
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers 
--PER day

Select date, SUM(new_cases) as TotalCases ,
sum(cast(new_deaths as int))as TotalDeaths,
ROUND(SUM(CAST(new_deaths AS INT)) / SUM(new_cases) * 100, 2) AS DeathPercentage
from Covid_Deaths
where continent is not null
Group by date 
order by 1,2 

--------------
--Total cases
Select  SUM(new_cases) as TotalCases ,sum(cast(new_deaths as int))as TotalDeaths,sum(cast(new_deaths as int))/ SUM(new_cases)* 100 as DeathPercenttage
from Covid_Deaths
where continent is not null
order by 1,2 


--Looking at populuation vs Vaccinations

Select dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--USING COMMON TABLE EXPRESSIONS

With PopvsVac ( continent, location ,date, population,new_vaccinations,RollingPeopleVaccinated)
as (
Select dea.continent , dea.location,dea.date, dea.population, vac.new_vaccinations
,sum(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location , dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths dea
Join PortfolioProject..Covid_Vaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
      )

Select * , (RollingPeopleVaccinated/population) * 100
from PopvsVac


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_Deaths dea 
Join Covid_Vaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
