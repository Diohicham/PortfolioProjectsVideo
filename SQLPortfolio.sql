 
--SELECT *
--FROM Portfolio..CovidDeaths
--Select Data that we are going to be using 
--order by 3,4

--Select Location, date, total_cases, new_cases, total_deaths, population
--FROM Portfolio..CovidDeaths
--order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Canada

--Select Location, date, total_cases,total_deaths,( total_deaths / total_cases)*100 as DeathPercentage
--FROM Portfolio..CovidDeaths
--WHERE location like '%anada%'
--order by 1, 2

--Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

-- Select Location, date, population,total_cases,( total_cases / population)*100 as PercentagePopulationInfected
--FROM Portfolio..CovidDeaths
--WHERE location like '%anada%'
--order by 1, 2


--Looking at Countries with Highest Infection Rate compared to Population

--Select Location,  population, MAX(total_cases) ,MAX(( total_cases / population))*100 as PercentagePopulationInfected
--FROM Portfolio..CovidDeaths
--GROUP BY Location, Population
--order by PercentagePopulationInfected desc

-- Looking at Countries with Highest Death Count comparte to Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is not null
GROUP BY Location
ORDER BY TotalDeathCount desc

--Showing the continent with the highest death 

Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths
Where continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as totdeaths,  SUM(cast(new_deaths as int)) / SUM(New_Cases) *100 as DeathPerc
FROM Portfolio..CovidDeaths
WHERE continent is not null
GROUP BY date
order by 1,2

 --Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order by dea.Location,
dea.Date) as RollingPeopleVaccinated

From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	ON dea.location = vac.location	
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
 


--TEMP TABLE

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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
USE Portfolio
GO
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfolio..CovidDeaths dea
Join Portfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
