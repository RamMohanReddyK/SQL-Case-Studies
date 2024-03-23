/* Created 2 table named CovidDeaths_final, CovidVaccinations_Final from TOTAL DATASET */

-- Skills used are ALIASING,Partition By, Subquery, DATA_TYPE Convertion,  Aggregate Functions, GROUP BY, ORDER BY,  Temp_tables, Views

-- 1. Lets Filter based on Deaths, cases, Population and see if NULL values from Continents and Date

SELECT CD.continent, CD.location, CD. date, CD.total_cases, CD.total_deaths, CD.population
FROM [PortFolio1].[dbo].[CovidDeaths_final] as CD
WHERE CD.continent IS NULL AND CD.location is NULL AND CD.date is NULL

/* NO NULL VAUES of CONTINENT, LOCATION, DATE, so we can start our EDA */


-- 2. Total Cases, Deaths, Likelyhood of dying in CANADA (Death Percentage) by April'2021


SELECT MAX(CD.total_deaths) AS CANADA_DEATHS  ,MAX(CD.total_cases)  AS CANADA_CASES ,(MAX((CD.total_deaths)) / MAX((CD.total_cases)))*100  AS DP
FROM [PortFolio1].[dbo].[CovidDeaths_final] as CD
WHERE CD.location LIKE 'CANADA%'

/* RESULT :
CANADA_DEATHS	CANADA_CASES	DP
9977	1228367	0.812216544404075 */

-- 3. What percentage of population infected with Covid in the World

SELECT location,date, total_cases, total_deaths, population, (CAST(total_cases AS INT)/population)*100 AS InfPop
FROM  [PortFolio1].[dbo].[CovidDeaths_final] as CD


-- 4. Countries with Highest Infection Rate compared to Population

SELECT location, population,MAX(CD.total_cases) As AllCases,MAX(CD.total_cases/CD.Population)*100 AS Infected_Population
FROM  [PortFolio1].[dbo].[CovidDeaths_final] as CD
GROUP BY location, population
ORDER BY Infected_Population DESC

-- 5. Continents with Highest Death Count per Population

SELECT location, population, MAX(CAST(CD.total_deaths AS INT)) As Countrydeaths
FROM  [PortFolio1].[dbo].[CovidDeaths_final] as CD
WHERE continent is NULL
GROUP BY location, population
ORDER BY Countrydeaths DESC

--6. Worldwide stats New Deaths , New cases, DP for New Cases, Can Use CASE WHEN for 0 Cases to shows '0' Cases and Comment as No New Cases

SELECT  SUM(CAST(new_cases AS float)) AS TOTAL_NEW_CASES,SUM(CAST(new_deaths AS float)) AS TOTAL_NEW_DEATHS, (SUM(CAST(new_deaths AS FLOAT))/SUM(CAST(new_cases AS FLOAT)))*100 AS DPNew
FROM  [PortFolio1].[dbo].[CovidDeaths_final] as CD
WHERE new_cases <> 0
--GROUP BY cd.date


--- Second Table Vaccinations using only New Cases and Rolling the count of vaccines

SELECT CD.location, CD.Date, CD.Population, CV.new_vaccinations, SUM(CONVERT(float, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.Date) AS ROLLING_VACCOUNT
FROM CovidDeaths_final CD
JOIN CovidVaccinations_Final CV ON CD.location = CV.location and CD.date = CV.date
WHERE CV.total_vaccinations IS NOT NULL
ORDER BY 1,2

-- CTE (COMMON TABLE EXPR)

WITH PopVsVac ( location, Date, Population, new_vaccinations,ROLLING_VACCOUNT) AS

(SELECT CD.location, CD.Date, CD.Population, CV.new_vaccinations, SUM(CONVERT(float, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.Date) AS ROLLING_VACCOUNT
FROM CovidDeaths_final CD
JOIN CovidVaccinations_Final CV ON CD.location = CV.location and CD.date = CV.date
WHERE CV.total_vaccinations IS NOT NULL

)
SELECT *, (ROLLING_VACCOUNT/Population)*100 As VP
FROM PoPVsVac


-- Temporary tables

DROP TABLE IF EXISTS #Temp_VP
CREATE TABLE #Temp_VP (

LOCATION nvarchar(300),
Date datetime,
population numeric,
new_vac numeric,
ROLLING_VACCOUNT Float
)

INSERT INTO #Temp_VP

SELECT CD.location, CD.Date, CD.Population, CV.new_vaccinations, SUM(CONVERT(float, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.Date) AS ROLLING_VACCOUNT
FROM CovidDeaths_final CD
JOIN CovidVaccinations_Final CV ON CD.location = CV.location and CD.date = CV.date
WHERE CV.total_vaccinations IS NOT NULL
ORDER BY 1,2

SELECT location,(ROLLING_VACCOUNT/population)*100 as VP
FROM #Temp_VP


--- Creating Views, later for Viz


CREATE VIEW Temp_VP_VIEW AS

SELECT CD.location, CD.Date, CD.Population, CV.new_vaccinations, SUM(CONVERT(float, CV.new_vaccinations)) OVER (PARTITION BY CD.location ORDER BY CD.location, CD.Date) AS ROLLING_VACCOUNT
FROM CovidDeaths_final CD
JOIN CovidVaccinations_Final CV ON CD.location = CV.location and CD.date = CV.date
--WHERE CV.total_vaccinations IS NOT NULL
--ORDER BY 1,2


Select location, (ROLLING_VACCOUNT/population)*100 as VP
FROM Temp_VP_VIEW