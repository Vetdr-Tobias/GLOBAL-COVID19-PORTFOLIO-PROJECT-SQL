SELECT*
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

---SELECT*
---FROM PortfolioProject..CovidVaccinations
---ORDER BY 3,4

---SELECT DATA WE ARE GOING TO BE USING
SELECT LOCATION,DATE,TOTAL_CASES,NEW_CASES,TOTAL_DEATHS,POPULATION
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

---LOOKING AT TOTAL CASES VS TOTAL DEATHS WORLDWIDE
SELECT LOCATION,DATE,TOTAL_CASES,TOTAL_DEATHS,(total_deaths/total_cases)* 100 AS DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


---LOOKING AT TOTAL CASES VS TOTAL DEATHS AFRICA
SELECT LOCATION,DATE,TOTAL_CASES,TOTAL_DEATHS,(total_deaths/total_cases)* 100 AS DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE 'AFRICA'
ORDER BY 1,2

---LOOKING AT TOTAL CASES VS TOTAL DEATHS NIGERIA
SELECT LOCATION,DATE,TOTAL_CASES,TOTAL_DEATHS,(total_deaths/total_cases)* 100 AS DEATHPERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE 'NIGERIA'
ORDER BY 1,2

---LOOKING AT TOTAL CASES VS POPULATION TO SHOW THE POPULATION GOT COVID IN NIGERIA
SELECT LOCATION,DATE,POPULATION, TOTAL_CASES,(total_cases/population)* 100 AS POPULATION_PERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE 'NIGERIA'
ORDER BY 1,2

---LOOKING AT TOTAL CASES VS POPULATION TO SHOW THE POPULATION GOT COVID IN AFRICA
SELECT LOCATION,DATE,POPULATION, TOTAL_CASES,(total_cases/population)* 100 AS POPULATION_PERCENTAGE
FROM PortfolioProject..CovidDeaths
WHERE LOCATION LIKE 'AFRICA'
ORDER BY 1,2

---LOOKING AT COUNTRY WITH THE HIGHEST COVID INFECTION RATES COMPARED TO POPULATION
SELECT LOCATION,POPULATION, MAX(TOTAL_CASES) AS HIGHEST_INFECTION_COUNT,MAX(total_cases/population)* 100 AS PERCENTAGEPOPULATION_INFECTED
FROM PortfolioProject..CovidDeaths
---WHERE LOCATION LIKE 'NIGERIA'
GROUP BY location,population
ORDER BY PERCENTAGEPOPULATION_INFECTED 

SELECT LOCATION,POPULATION, MAX(TOTAL_CASES) AS HIGHEST_INFECTION_COUNT,MAX(total_cases/population)* 100 AS PERCENTAGEPOPULATION_INFECTED
FROM PortfolioProject..CovidDeaths
---WHERE LOCATION LIKE 'NIGERIA'
GROUP BY location,population
ORDER BY PERCENTAGEPOPULATION_INFECTED DESC

---LOOKING AT COUNTRY WITH THE HIGHEST COVID DEATH COUNT PER POPULATION
SELECT LOCATION,MAX(CAST(total_deaths AS INT)) AS TOTALDEATH_COUNT
FROM PortfolioProject..CovidDeaths
---WHERE LOCATION LIKE 'NIGERIA'
WHERE CONTINENT IS NOT NULL
GROUP BY location
ORDER BY TOTALDEATH_COUNT DESC

---LOOKING AT CONTINENT WITH THE HIGHEST COVID DEATH COUNT PER POPULATION
SELECT location,MAX(CAST(total_deaths AS INT)) AS TOTALDEATH_COUNT
FROM PortfolioProject..CovidDeaths
---WHERE LOCATION LIKE 'NIGERIA'
WHERE CONTINENT IS NULL
GROUP BY location
ORDER BY TOTALDEATH_COUNT DESC

---GLOBAL COVID NUMBERS
SELECT SUM(NEW_CASES) AS TOTAL_CASES,SUM(CAST(new_deaths AS INT)) AS TOTAL_DEATH, 
SUM(CAST(NEW_DEATHS AS INT))/SUM(NEW_CASES)*100 AS DEATH_PERCENTAGE
FROM PortfolioProject..CovidDeaths
---WHERE LOCATION LIKE 'NIGERIA'
WHERE CONTINENT IS NOT NULL
---GROUP BY location
ORDER BY 1,2

---LOOKING AT TOTAL POPULATION VS VACCINATION
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
DEA.DATE) AS CUMMULATIVEVACCINATED_POPULATION
---,(CUMMULATIVEVACCINATED_POPULATION/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.CONTINENT IS NOT NULL
ORDER BY 2,3


---USE CTE
WITH POPVSVAC(CONTINENT, LOCATION, DATE,POPULATION,NEW_VACCINATION,CUMMULATIVEVACCINATED_POPULATION)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
DEA.DATE) AS CUMMULATIVEVACCINATED_POPULATION
---,(ROLLINGPEOPLEVACCINATED/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.CONTINENT IS NOT NULL
---ORDER BY 2,3
)
SELECT*,(CUMMULATIVEVACCINATED_POPULATION/POPULATION)*100 AS PERCENTAGEPOPULATION_VACCINATED
FROM POPVSVAC

---TEMP TABLE
DROP TABLE IF EXISTS #PERCENTAGEPOPULATIONVACCINATED
CREATE TABLE #PERCENTAGEPOPULATIONVACCINATED
(
CONTINENT NVARCHAR (255),
LOCATION NVARCHAR (255),
DATE DATETIME,
POPULATION NUMERIC,
NEW_VACCINATION NUMERIC,
CUMMULATIVEVACCINATED_POPULATION NUMERIC
)

INSERT INTO #PERCENTAGEPOPULATIONVACCINATED
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
DEA.DATE) AS CUMMULATIVEVACCINATED_POPULATION
---,(ROLLINGPEOPLEVACCINATED/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.CONTINENT IS NOT NULL
---ORDER BY 2,3
SELECT*,(CUMMULATIVEVACCINATED_POPULATION/POPULATION)*100 AS PERCENTAGEPOPULATION_VACCINATED
FROM #PERCENTAGEPOPULATIONVACCINATED



CREATE VIEW PERCENTAGEPOPULATIONVACCINATED AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
DEA.DATE) AS CUMMULATIVEVACCINATED_POPULATION
---,(ROLLINGPEOPLEVACCINATED/population)*100
FROM PortfolioProject..CovidDeaths DEA
JOIN PortfolioProject..CovidVaccinations VAC
ON DEA.location = VAC.location
AND DEA.date = VAC.date
WHERE DEA.CONTINENT IS NOT NULL
---ORDER BY 2,3


SELECT*
FROM PERCENTAGEPOPULATIONVACCINATED 
