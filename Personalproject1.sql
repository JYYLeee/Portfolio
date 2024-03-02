--Initial testing of tables. 
Select *
From Portfolioproject..CovidDeaths
Where continent is not null 
Order by 3, 4

--Select *
--From Portfolioproject..CovidVaccines
--order by 3, 4

--Selecting data that we are going to be using. testing out to see any errors. 
Select Location, date, total_cases, new_cases, total_deaths, population 
From Portfolioproject..CovidDeaths
order by 1, 2

--Looking at total cases vs total deaths (US) 
--All the fields in DB saved as varchar, had to convert data types. 
--Shows likelihood of dying if you contract covid in your country. 

Select location,total_cases,total_deaths, 
(CONVERT(datetime,date,101))as ActualDate,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage 
 
from PortfolioProject..covidDeaths
where location like '%states%'
order by 1, ActualDate


---Looking at Total cases vs. Population. 
---Shows what percentage of population got Covid.

Select location,total_cases, population,
(CONVERT(datetime,date,101)) AS ActualDate,
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
 
from PortfolioProject..covidDeaths
where location like '%states%'
order by 1, ActualDate


--Looking at countries with highest infection rate compared to population 
--highest infection rate = MAX total_cases.

Select location, Population, MAX(cast(total_cases as int)) as HighestInfectionCount,
(MAX(totaL_cases)/ NULLIF(CONVERT(float, population), 0)) * 100 AS PercentPopulationInfected
 
From PortfolioProject..covidDeaths
--where location like '%states%'
Group by location, Population 
Order by PercentPopulationInfected desc


--Showing countries with highest death count per Population.
--Data like World and high income + lower middle income shows up... incorrect. 

Select location,MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..covidDeaths
Where continent is not null 
Group by Location
order by TotalDeathCount desc

--Breaking down things by continent
--Blank space should be WORLDWIDE death count.

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc 

-- Showing continents with highest death count per population 

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolioproject..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc 

--GLOBAL NUMBERS

--Changed every varchar to int / date time. 
--0 was saved in new_deaths instead of null, could not divide by zero so created where clause. 

Select CAST(date as datetime) as Date, SUM(cast(new_cases as int)) as total_cases, SUM(cast(new_deaths as int)) 
as total_deaths,
SUM(CAST(new_deaths as float)) / SUM(CAST(new_cases as float)) * 100 AS DeathPercentage
 
From PortfolioProject..covidDeaths
--where location like '%states%'
where continent is not null AND new_deaths != 0
Group by date
order by 1,2

--JOINS 
-- Looking at Total Population Vs. Vaccinations.


Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccines vac
	On dea.location = vac.location 
where dea.continent is not null
order by 2,3

--Making a Rolling count with partition by

--Make CTE for rolling people vaccinated. 
With PopVsVac (Continent, Location, Date, Population,new_vaccinations, RollingPeopleVaccinated)
as (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From Portfolioproject..CovidDeaths dea
Join Portfolioproject..CovidVaccines vac
	On dea.location = vac.location 
where dea.continent is not null

)
Select *
From PopVsVac