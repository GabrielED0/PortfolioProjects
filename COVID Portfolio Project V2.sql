Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 3, 4

Select *
From [Portfolio Project].dbo.CovidVaccinations
Order by 3,4

---- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Order by 1, 2

---- Total cases vs Total Deaths

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as DeathPercentage
From [Portfolio Project]..CovidDeaths
Order by 1, 2

---- What is the death % for Iceland?
---- Shows likelihood of dying if you contract covid in Iceland

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location = 'Iceland'
Order by 2

---- What about the US?
---- Shows likelihood of dying if you contract covid in the US

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location like '%states%'
Order by 1,2

---- And Portugal?
---- Shows likelihood of dying if you contract covid in Portugal

Select location, date, total_cases, total_deaths, round((total_deaths/total_cases)*100, 2) as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where location = 'Portugal'
Order by 1,2

---- Looking at Total Cases vs Population
---- Shows what % of population got covid
---- An infection rate(or incident rate) is the probability or risk of an infection in a population

Select location, date, population, total_cases, round((total_cases/population)*100, 2) as InfectionRate
From [Portfolio Project]..CovidDeaths
Where location = 'Portugal'
Order by 1,2


Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

---- Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

---- Break things down by continent

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null
Group by location
Order by TotalDeathCount desc

---- Showing continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc

---- Global numbers

Select date, SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group By date
Order by 1,2

---- Global numbers (1)

Select SUM(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumNewVaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


-- Using CTE
-- Let's find out the % of population that is vaccinated.

With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, SumNewVaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumNewVaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, round((SumNewVaccinations/Population)*100, 2)
From PopvsVac


-- Using Temp Table
-- Another way of displaying the previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_vaccinations numeric,
SumNewVaccinations numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumNewVaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

--Select *, round((SumNewVaccinations/Population)*100, 2)
--From #PercentPopulationVaccinated


-- Creating View to store data for later visualisations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as SumNewVaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated