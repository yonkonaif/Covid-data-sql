-- total cases vs deaths
SELECT Location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / total_cases) * 100 as deathP
FROM CovidDeaths2
WHERE location LIKE 'saudi%'
ORDER by 1,2

--total cases vs population

SELECT location, date, population, total_cases, (total_cases / population) * 100 as CasesVsPopulation
FROM CovidDeaths2
WHERE location LIKE '%saudi%'
ORDER by 1, 2

--highest infection rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases) / population) * 100 as PrecentOfPopulationInfected
FROM CovidDeaths2
--WHERE location LIKE '%states%'
GROUP by location, population
ORDER by PrecentOfPopulationInfected DESC


--countries with highest death

SELECT location, MAX(total_deaths) as Total_Death_Count 
FROM CovidDeaths2
WHERE continent IS NOT NULL
Group by location
ORDER by Total_Death_Count DESC


--continent with highest death

SELECT location, MAX(total_deaths) as Total_Death_Count 
FROM CovidDeaths2
WHERE continent IS NULL
Group by location
ORDER by Total_Death_Count DESC


--Global numbers

--death per
SELECT date, SUM(CAST(new_cases as float)) as totalCases, SUM(CAST(new_deaths as float)) as totalDeaths, 
	(SUM(CAST(new_deaths as float)) / SUM(CAST(new_cases as float))) * 100 as deathPercentage
FROM CovidDeaths2
WHERE continent IS NOT NULL
GROUP by date
ORDER by 1,2

--all

SELECT SUM(CAST(new_cases as float)) as totalCases, SUM(CAST(new_deaths as float)) as totalDeaths, 
	(SUM(CAST(new_deaths as float)) / SUM(CAST(new_cases as float))) * 100 as deathPercentage
FROM CovidDeaths2
WHERE continent IS NOT NULL
ORDER by 1,2


--vaccinantions

SELECT *
FROM CovidVaccinations2

--total pop vs vac

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM CovidDeaths2 as dea
JOIN CovidVaccinations2 as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

--rolling up new vac

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as totalVac
FROM CovidDeaths2 as dea
JOIN CovidVaccinations2 as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL


--rolling up new vac + per

WITH PopvsVac (continent, location, date, population, New_Vaccinations, totalVac)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION by dea.location ORDER by dea.location, dea.date) as totalVac
FROM CovidDeaths2 as dea
JOIN CovidVaccinations2 as vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
)

SELECT *, (totalVac / population) * 100 as per
FROM PopvsVac
