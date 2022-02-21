

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

-- Selecting data to be used

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order By 1,2

-- Calculating likelihood of death if you get infected for USA

Select Location, date, total_cases, total_deaths,
   (total_deaths/total_cases)*100 AS Death_Rate
From PortfolioProject..CovidDeaths
Where Location like 'United_States'
Order By 1,2
-- Currently if you get COVID you have 1.2% chance of dying

-- Calculating what percentage of population has had COVID in USA

Select Location, date, total_cases, Population,
   (total_cases/population)*100 AS Infection_Rate
From PortfolioProject..CovidDeaths
Where Location like 'United_States'
Order By 1,2
-- Currently about 24% of population has had covid


--Calculating what countries have highest rate of infection vs population
Select Location, max(total_cases) AS Highest_Infected, Population,
   (max(total_cases)/population)*100 AS Percent_Infected
From PortfolioProject..CovidDeaths
Group By Location, Population
Order By Percent_Infected Desc
-- Faeroe Islands has by far the highest % infected at 65%
-- USA is 38th

--Calcuating what countries have had the higest death count
Select Location, max(cast(total_deaths as INT)) AS Highest_Deaths 
From PortfolioProject..CovidDeaths
where Continent is not NULL
Group By Location
Order By Highest_Deaths desc
-- USA is 1st by about 300,000 over Brazil (935k vs 644k)


--Same query but by Continent instead of Country
Select Location, max(cast(total_deaths as INT)) AS Highest_Deaths 
From PortfolioProject..CovidDeaths
where Continent is NULL
Group By Location
Order By Highest_Deaths desc
-- Europe is now 1st with 1688k


--Calculating global numbers
Select date, sum(new_cases) AS Total_cases, sum(cast(new_deaths as INT)) AS Total_Deaths,
   sum(cast(new_deaths as INT))/sum(new_cases)*100 AS Global_Death_Rate
From PortfolioProject..CovidDeaths
Where continent is not NULL
Group by Date
Order By 1,2
--Death rate started at about 2% and over time has decreased to about 0.4%


--Calculationg rate of Vaccination for Countries
Select Dea.Continent, Dea.Location, Dea.Date, Dea.population, Vac.new_vaccinations,
       sum(cast(Vac.new_vaccinations as INT)) OVER (Partition by Dea.Location Order by Dea.Location, Dea.Date) AS RollingVaxCount
From PortfolioProject..CovidDeaths AS Dea
Join PortfolioProject..CovidVaccinations As Vac
   On Dea.location = Vac.location
   AND Dea.date = Vac.date
Where Dea.continent is not NULL
Order By 2,3;

-- Using CTE
With PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingVaxCount)
AS 
(
Select Dea.Continent, Dea.Location, Dea.Date, Dea.population, Vac.new_vaccinations,
       sum(cast(Vac.new_vaccinations as INT)) OVER (Partition by Dea.Location Order by Dea.Location, Dea.Date) AS RollingVaxCount
From PortfolioProject..CovidDeaths AS Dea
Join PortfolioProject..CovidVaccinations As Vac
   On Dea.location = Vac.location
   AND Dea.date = Vac.date
Where Dea.continent is not NULL)
--Order By 2,3
Select *, (RollingVaxCount/Population)*100
From PopvsVac


--Creating a View for later Vizualizations

Create View PercentPopulationVaccinated AS
Select Dea.Continent, Dea.Location, Dea.Date, Dea.population, Vac.new_vaccinations,
       sum(cast(Vac.new_vaccinations as INT)) OVER (Partition by Dea.Location Order by Dea.Location, Dea.Date) AS RollingVaxCount
From PortfolioProject..CovidDeaths AS Dea
Join PortfolioProject..CovidVaccinations As Vac
   On Dea.location = Vac.location
   AND Dea.date = Vac.date
Where Dea.continent is not NULL


Select *
From PercentPopulationVaccinated