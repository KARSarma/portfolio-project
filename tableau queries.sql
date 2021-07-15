Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..covid_deaths
--Where location like 
where continent is not null 
--Group By date
order by 1,2

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..covid_deaths
--Where location like ''
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc 

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
--Where location like ''
Group by Location, Population
order by PercentPopulationInfected desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..covid_deaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


Select dea.continent, dea.location, dea.date, dea.population
, MAX(vac.total_vaccinations) as PeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..covid_deaths dea
Join PortfolioProject..covid_vacination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
group by dea.continent, dea.location, dea.date, dea.population
order by 1,2,3
