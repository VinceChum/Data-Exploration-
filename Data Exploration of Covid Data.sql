/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/
SELECT *
FROM [Portfolio Project]..CovidDeaths$
ORDER BY 3, 4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations$
--ORDER BY 3, 4

--Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project]..CovidDeaths$
Where continent is not null
ORDER BY 1, 2

--Looking at Total Cases vs Total Deaths
--shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
WHERE location like '%Philippines%'
and continent is not null
ORDER BY 1, 2

--Looking at Total Cases vs. Population
--Shows what percentage of population got covid
SELECT location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%Philippines%'
ORDER BY 1, 2


--Looking at countries with Highest Infection Rate compared to Population

SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as
PercentPopulationInfected
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%Philippines%'
GROUP BY location, population
ORDER BY PercentPopulationInfected desc


--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%Philippines%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--Let's Break Things Down by Continent

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%Philippines%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast
(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths$
--WHERE location like '%state%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



Select *
FROM [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




-- Using Temp Table to perform Calculation on Partition By in previous query

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
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 as PercentageVaccinated
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths$ dea
Join [Portfolio Project]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


Select *
From PercentPopulationVaccinated