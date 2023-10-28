

SELECT * 
FROM CovidDeaths
ORDER BY 3,4;


--SELECT * 
--FROM CovidVaccinations
--ORDER BY 3,4;

-- Selct Data that I am going to be using 

SELECT location ,date ,population ,total_cases , new_cases,total_deaths
FROM CovidDeaths

ORDER BY 1,2; 

-- Looking at Total cases VS Total Deaths 
SELECT location ,date  ,total_cases  ,total_deaths ,(total_deaths / total_cases) * 100 As DeathPerctange 
FROM CovidDeaths
--Where location like '%states%'
ORDER BY 1,2;



-- Looking at Total cases VS Population 
SELECT location ,date, population  ,total_cases   ,(total_cases / population) * 100 As PercentPopulationInfected 
FROM CovidDeaths
--Where location like '%states%'
ORDER BY 1,2;


-- Looking at countries with heighst Infection Rate comapred to Population 

SELECT location , population  ,MAX(total_cases) AS HighestIfectionCount    ,
	MAX((total_cases / population)) * 100 As PercentPopulationInfected 
FROM CovidDeaths
GROUP BY location , population
ORDER BY PercentPopulationInfected desc;



-- Showing Countries with Heighst Death Count per  population

SELECT location , MAX(CAST (total_deaths AS INT )) As TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount desc;


-- Let's break down by continent 

-- Showing continent with the heighst death count per puplation
SELECT continent , MAX(CAST (total_deaths AS INT )) As TotalDeathCount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount desc;


-- Global Numbers 
SELECT date  , SUM(new_cases) As total_cases  , SUM (cast(new_deaths as int)) As total_deaths,
(SUM(new_cases) /SUM (cast(new_deaths as int))) as DeathPerctange
FROM CovidDeaths
Where continent is not null 
Group by date
ORDER BY 1,2;




--Looking at total Population Vs total vaccinations 

select dea.continent ,dea.location ,dea.date, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER  (Partition by dea.location order by dea.location, 
dea.date ) as RollingDateVaccinated
From CovidDeaths dea
Join CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null
order by 2,3



-- Use CTE 

with PopVsVac (continent ,location,population ,date ,new_vaccinations,RollingDateVaccinated)
as
(
select dea.continent ,dea.location,dea.population ,dea.date, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER  (Partition by dea.location order by dea.location, 
dea.date ) as RollingDateVaccinated
From CovidDeaths dea
Join CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

)

select * ,(RollingDateVaccinated / population) * 100
from PopVsVac;



--TEMp Table 

Drop Table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
population numeric ,
date Datetime,
new_vaccinations numeric,
RollingDateVaccinated numeric
)

Insert Into #PercentPopulationVaccinated

select dea.continent ,dea.location,dea.population ,dea.date, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER  (Partition by dea.location order by dea.location, 
dea.date ) as RollingDateVaccinated
From CovidDeaths dea
Join CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
--Where dea.continent is not null


select * ,(RollingDateVaccinated / population) * 100
from #PercentPopulationVaccinated;



-- Creating View to store data for later visualization
create view PercentPopulationVaccinated as

select dea.continent ,dea.location,dea.population ,dea.date, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER  (Partition by dea.location order by dea.location, 
dea.date ) as RollingDateVaccinated
From CovidDeaths dea
Join CovidVaccinations vac 
ON dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null

