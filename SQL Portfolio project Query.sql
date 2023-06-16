Select *
from Covid_Deaths
where continent is not null
Order By 3,4

Select *
from Covid_Vaccinations
where continent is not null
Order By 3,4

select Location, date, total_cases, New_cases, total_deaths, population
From Covid_Deaths
where continent is not null
order by 1,2

--LOOKING AT THE TOAL CASES VS TOTAL DEATHS, SHOWS THE LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY

select Location, date, total_cases, total_deaths, (cast(total_deaths as float)/total_cases)*100 as DeathPercentage
From Covid_Deaths
where location like '%Nigeria%'
where continent is not null
order by 1,2

--LOOKING AT TOTAL CASES VS POPULATION, SHOWING WHAT PERCENTAGE GOT COVID

Select location, date, population, total_cases,  (cast(total_cases as float)/Population)*100 as Death_Percentage
From Covid_Deaths
where location like '%Nigeria%'
where continent is not null
order by 1,2

--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

Select location, population, max(total_cases) as HighestInfectionCount,  max((cast(total_cases as float)/Population))*100 as PercentPopulationInfected
From Covid_Deaths
Group By location, population
order by PercentPopulationInfected desc

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid_Deaths
where continent is not null
Group By location
order by TotalDeathCount desc 

--BREAK DOWN BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Covid_Deaths
where continent is not null
Group By continent
order by TotalDeathCount desc 

--GLOBAL NUMBERS

Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From Covid_Deaths
where continent is not null
--Group By date,
order by 1,2

SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths,
CASE
    WHEN SUM(new_cases) <> 0
    THEN (SUM(CAST(new_deaths AS int)) * 100.0) / SUM(new_cases)
    ELSE 0
END AS death_percentage
FROM Covid_Deaths
WHERE continent IS NOT NULL 
--AND location LIKE '%states%'
GROUP BY date
ORDER BY date;

--LOOKING AT TOTAL POPULATION VS VACCINATIONS

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, Sum(Cast(Vac.new_vaccinations as bigint)) Over (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from Covid_Deaths Dea
Join Covid_Vaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
order by 2,3  

--USE CTE
With PopvsVac (continent, location, date, population, new_vaccination, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, Sum(Cast(Vac.new_vaccinations as bigint)) Over (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from Covid_Deaths Dea
Join Covid_Vaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3 
)
Select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--TEMP TABLE

Drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, Sum(Cast(Vac.new_vaccinations as bigint)) Over (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from Covid_Deaths Dea
Join Covid_Vaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
--where Dea.continent is not null
--order by 2,3 

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--CREATING VIEW TO STORE DATA FOR VISUALIZATION

Create view PercentPopulationVaccinated as 
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
, Sum(Cast(Vac.new_vaccinations as bigint)) Over (partition by Dea.location order by Dea.location, Dea.date) as RollingPeopleVaccinated
from Covid_Deaths Dea
Join Covid_Vaccinations Vac
on Dea.location = Vac.location
and Dea.date = Vac.date
where Dea.continent is not null
--order by 2,3 

Select * from PercentPopulationVaccinated