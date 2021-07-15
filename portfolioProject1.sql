
Select * 
From PortfolioProject..covid_deaths
order by 3,4


Select * 
From PortfolioProject..covid_vacination
order by 3,4

Select location, date, total_cases, new_cases, population
From PortfolioProject..covid_deaths
order by 1,2

-- we are looking at total cases vs total deaths
--shows the likelihood of death in a perticular country(IN THIS CASE INDIA)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage, population
From PortfolioProject..covid_deaths
where location='india'
order by 1,2

--We are looking at total cases vs population
Select location, date, total_cases, total_deaths, (total_cases/population)*100 as PercentOfPopulationInfected, population
From PortfolioProject..covid_deaths
where location='india'
order by 1,2

--looking at countries with highest infection rate to population
Select location, Max(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentOfPopulationInfected , population
From PortfolioProject..covid_deaths
Group by Location, Population
order by PercentOfPopulationInfected desc

--showing countries with highest death count
Select location, Max(cast(total_deaths as int)) as MaxDeathCount
From PortfolioProject..covid_deaths
--WHERE date >= '20081220 00:00:00.000'
Group by Location
order by MaxDeathCount desc

--deaths from may 1st
Select location, Max(cast(total_deaths as int)) as total_deaths 
From PortfolioProject..covid_deaths
WHERE date >= 2021-05-01 
Group by Location 
order by total_deaths desc

--total population vs vaccination ( int data type did not work, had to use BIGINT)

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
--, (PeopleVaccinated/population)*100
--From PortfolioProject..covid_deaths dea
--Join PortfolioProject..covid_vacination vac
	--On dea.location = vac.location
	--and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM( cast (vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vacination vac
On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3



-- Using CTE to perform Calculation on Partition 

With PopvsVac (Continent, Location, Date, Population, new_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as PeopleVaccinated
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vacination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (PeopleVaccinated/Population)*100
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
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM( cast (vac.new_vaccinations as BIGINT)) OVER (Partition by dea.Location order by dea.location, dea.date) as PeopleVaccinated
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vacination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations
CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vacination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

