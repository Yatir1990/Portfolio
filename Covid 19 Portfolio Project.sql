Select *
From ProtfolioProjects..CovidDeaths
Where continent is not Null
Order by 3,4 

--Select *
--FROM ProtfolioProjects..CovidVaccinations
--Order by 3,4 

Select location, date, total_cases, new_cases, total_deaths, population
From ProtfolioProjects..CovidDeaths
Where continent is not Null
Order by 1,2 


-- Total Cases vs Total Death
-- Shows liklihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From ProtfolioProjects..CovidDeaths
Where location like '%state%'
and continent is not Null
Order by 1,2 


-- Total Cases vs Population
-- Shows what percentage of population got covid

Select location, date, population, total_cases, (total_cases/population)*100 as percent_pop_inf
From ProtfolioProjects..CovidDeaths
--Where location like '%state%'
Where continent is not Null
Order by 1,2 


-- Countries with Highest Infaction Eate compared to Population

Select location, population, Max(new_cases) As highest_inf_count, Max((new_cases/population))*100 as percent_pop_inf
From ProtfolioProjects..CovidDeaths
--Where location like '%state%'
Where continent is not Null
Group by population, location
Order by 4 desc


-- Countries with Highest Death Count per Population

Select location, Max(cast(total_deaths as int)) As total_death_count
From ProtfolioProjects..CovidDeaths
--Where location like '%state%'
Where continent is not Null
Group by location
Order by 2 desc


-- Continent with Highest Death Count per Population

Select continent, Max(cast(total_deaths as int)) As total_death_count
From ProtfolioProjects..CovidDeaths
--Where location like '%state%'
Where continent is not Null
Group by continent
Order by 2 desc


-- Global Numbers

Select Sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, Sum(Cast(new_deaths as int))/Sum(new_cases)*100 as death_percentage
From ProtfolioProjects..CovidDeaths
Where continent is not Null
--Group by date
Order by 1,2


Select *
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Populations vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by 
		dea.location, dea.date) as rolling_people_vaccinated 
		--, (rolling_people_vaccinated/population)*100
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2, 3


-- Use CTE

With pop_vs_vac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by 
		dea.location, dea.date) as rolling_people_vaccinated 
		--, (rolling_people_vaccinated/population)*100
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2, 3
)
Select *, (rolling_people_vaccinated/population)*100 as percent_people_vaccinated
From pop_vs_vac


-- Temp Table

--Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric,
new_vaccinations numeric, 
rolling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	Sum(Cast(vac.new_vaccinations as bigint)) Over (Partition by dea.location Order by 
		dea.location, dea.date) as rolling_people_vaccinated 
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

Select *, (rolling_people_vaccinated/population)*100 as percent_people_vaccinated
From #PercentPopulationVaccinated
Order by 1,2,3


-- Creating View to store data for later visualizations

Drop View PercentPopulationVaccinated
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	Sum(convert(bigint, vac.new_vaccinations)) Over (Partition by dea.location Order by 
		dea.location, dea.date) as rolling_people_vaccinated 
From ProtfolioProjects..CovidDeaths dea
Join ProtfolioProjects..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 1, 2


Select *
From PercentPopulationVaccinated