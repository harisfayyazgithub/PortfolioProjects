SELECT *
FROM portfolioproject.coviddeaths
order by 3,4

SELECT *
FROM portfolioproject.covidvaccinations
order by 3,4

--Selecting data to be used

SELECT Location,date,total_cases,new_cases,total_deaths,population
FROM portfolioproject.coviddeaths
ORDER BY 1,2

--Looking at Total Caes VS Total Deaths
--Shows likelihood of dying if contract covid is countries having 'istan' in them

SELECT Location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM portfolioproject.coviddeaths
WHERE location like '%istan%'
ORDER BY 1,2

--Looking at Total cases VS Population
--Shows what percentage of population got Covid

SELECT Location,date,population, total_cases,(total_cases/population)*100 AS Percent_Population_Infected
FROM portfolioproject.coviddeaths
WHERE location like '%istan%'
ORDER BY 1,2

--Looking at countries at Highest infection rate compared to Population

SELECT
    Location, Population,
    MAX(total_cases) AS Highest_infection_Count,
    (MAX(total_cases) / MAX(population)) * 100 AS Percent_Population_Infected
FROM
    portfolioproject.coviddeaths
GROUP BY
    Location, Population
ORDER BY
    Percent_Population_Infected DESC;
    
--Showing Countries with Highest Death Count per Population

SELECT Location,MAX(total_deaths) as Total_Death_Count
FROM
	portfolioproject.coviddeaths
WHERE 
	continent is not null
GROUP BY
    Location
ORDER BY
    Total_Death_Count DESC;

--Showing Continent with highest death count

SELECT continent, MAX(total_deaths) as Total_Death_Count
FROM portfolioproject.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC;

--Global Numbers

SELECT Date,SUM(new_cases) AS Total_Cases,SUM(new_deaths) AS Total_Deaths,SUM(New_deaths)/SUM(New_Deaths)*100 AS Death_Percentage
FROM PortfolioProject.coviddeaths
WHERE Continent IS NOT NULL
GROUP BY Date
ORDER BY 1,2

--Covid Vaccinations
SELECT * 
FROM PortfolioProject.CovidVaccinations

--Joining Table

SELECT * 
FROM PortfolioProject.coviddeaths AS pc
INNER JOIN PortfolioProject.CovidVaccinations AS pv
	ON pc.location=pv.location 
	AND pc.date=pv.date

--Looking at Total Population VS Vaccination

SELECT pc.continent,pc.location,pc.date,pc.population,pv.new_vaccinations,
SUM(pv.new_vaccinations) OVER (Partition by pc.Location ORDER BY pc.location,pc.date) AS Rolling_People_Vaccinated
FROM PortfolioProject.coviddeaths AS pc
INNER JOIN PortfolioProject.CovidVaccinations AS pv
	ON pc.location=pv.location 
	AND pc.date=pv.date
WHERE pc.continent IS NOT NULL
ORDER BY 2,3

--USE CTE

WITH PopVSVac(Continent, Location, Date, Population, RollingPeopleVaccinated)
AS
(
    SELECT pc.continent, pc.location, pc.date, pc.population, pv.new_vaccinations,
    SUM(pv.new_vaccinations) OVER (PARTITION BY pc.Location ORDER BY pc.location, pc.date) AS Rolling_People_Vaccinated
    FROM PortfolioProject.coviddeaths AS pc
    INNER JOIN PortfolioProject.CovidVaccinations AS pv
    ON pc.location = pv.location 
    AND pc.date = pv.date
    WHERE pc.continent IS NOT NULL
)
SELECT * FROM PopVSVac;

--Temp Table

DROP TABLE if exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(225),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric
)


INSERT INTO #Percentpopulation
SELECT pc.continent, pc.location, pc.date, pc.population, pv.new_vaccinations,
    SUM(pv.new_vaccinations) OVER (PARTITION BY pc.Location ORDER BY pc.location, pc.date) AS Rolling_People_Vaccinated
    FROM PortfolioProject.coviddeaths AS pc
    INNER JOIN PortfolioProject.CovidVaccinations AS pv
    ON pc.location = pv.location 
    AND pc.date = pv.date
    WHERE pc.continent IS NOT NULL
    
--Create View to store for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT pc.continent, pc.location, pc.date, pc.population, pv.new_vaccinations,
    SUM(pv.new_vaccinations) OVER (PARTITION BY pc.Location ORDER BY pc.location, pc.date) AS Rolling_People_Vaccinated
FROM PortfolioProject.coviddeaths AS pc
INNER JOIN PortfolioProject.CovidVaccinations AS pv
    ON pc.locapercentpopulationvaccinatedtion = pv.location 
    AND pc.date = pv.date
WHERE pc.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated
