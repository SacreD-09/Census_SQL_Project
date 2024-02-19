USE census;

-- Query 1: Average Growth Rate by State
SELECT 
    state, CONCAT(ROUND(AVG(Growth) * 100, 2),'%') AS Avg_Growth_Pct
FROM
    data1
GROUP BY State;

--------------------------------------------------------------

-- Query 2: Average Sex Ratio by State
SELECT 
    state, ROUND(AVG(Sex_Ratio), 0) AS Avg_Sex_ratio
FROM
    data1
GROUP BY State
ORDER BY Avg_Sex_ratio DESC;

--------------------------------------------------------------

-- Query 3: Average Literacy Rate by State (Above 90%)
SELECT 
    state, ROUND(AVG(Literacy), 0) AS Avg_Literacy_rate
FROM
    data1
GROUP BY State
HAVING ROUND(AVG(Literacy), 0) > 90
ORDER BY Avg_Literacy_rate DESC;


--------------------------------------------------------------

-- Query 4: Top Three States with Highest Literacy Rates
SELECT 
    state, ROUND(AVG(Literacy), 0) AS Avg_Literacy_rate
FROM
    data1
GROUP BY State
ORDER BY Avg_Literacy_rate DESC
LIMIT 3;


--------------------------------------------------------------

-- Query 5: Joining Tables for District Data
SELECT 
    a.District,
    a.State,
    a.Growth,
    a.Sex_Ratio / 1000 AS sex_ratio,
    a.Literacy,
    b.Area_km2,
    b.Population
FROM
    data1 a
INNER JOIN data2 b ON a.District = b.District;


--------------------------------------------------------------

-- Query 6: Male and Female Population by District
SELECT 
    c.district,
    c.state,
    ROUND(c.population / (c.ratio + 1), 0) Male,
    ROUND((c.ratio * c.population / (c.ratio + 1)), 0) Female
FROM
    (SELECT 
        a.District,
        a.State,
        a.Growth,
        a.Sex_Ratio / 1000 AS ratio,
        a.Literacy,
        b.Area_km2,
        b.Population
    FROM
        data1 a
    INNER JOIN data2 b ON a.District = b.District) AS C;


--------------------------------------------------------------

-- Query 7: Male and Female Population by State
SELECT 
    state, SUM(males) Males, SUM(females) Females
FROM
    (SELECT 
        c.district,
        c.state state,
        ROUND(c.population / (c.sex_ratio + 1), 0) males,
        ROUND((c.population * c.sex_ratio) / (c.sex_ratio + 1), 0) females
    FROM
        (SELECT 
            a.district,
            a.state,
            a.sex_ratio / 1000 sex_ratio,
            b.population
        FROM
            data1 a
        INNER JOIN data2 b ON a.district = b.district) c) d
GROUP BY state;


--------------------------------------------------------------

-- Query 8: Total Literate and Illiterate People by District
SELECT 
    a.District,
    a.State,
    a.Growth,
    a.Literacy Litracy_Ratio,
    b.Population,
    ROUND(((a.Literacy / 100) * b.Population), 0) Total_literate_People,
    ROUND(((1 - (a.Literacy / 100)) * b.Population), 0) Total_illiterate_People
FROM
    data1 a
INNER JOIN data2 b ON a.District = b.District;


--------------------------------------------------------------

-- Query 9: Total Literate and Illiterate People by State
SELECT 
    State,
    SUM(Population) Population,
    SUM(Total_literate_People) Total_literate_People,
    SUM(Total_illiterate_People) Total_literate_People
FROM
    (SELECT 
        a.District,
        a.State,
        a.Growth,
        a.Literacy Litracy_Ratio,
        b.Population,
        ROUND(((a.Literacy / 100) * b.Population), 0) Total_literate_People,
        ROUND(((1 - (a.Literacy / 100)) * b.Population), 0) Total_illiterate_People
    FROM
        data1 a
    INNER JOIN data2 b ON a.District = b.District) c
GROUP BY State;


--------------------------------------------------------------

-- Query 10: Previous Population by District
SELECT 
    a.District,
    a.State,
    a.Growth,
    ROUND(Population / (1 + (growth / 100)), 0) Previous_census_population,
    b.Population
FROM
    data1 a
INNER JOIN data2 b ON a.District = b.District;


--------------------------------------------------------------

-- Query 11: Previous Population by State
SELECT 
    State,
    SUM(Previous_census_population) Previous_population,
    SUM(Population) Population
FROM
    (SELECT 
        a.District,
        a.State,
        a.Growth,
        ROUND(Population / (1 + (growth / 100)), 0) Previous_census_population,
        b.Population
    FROM
        data1 a
    INNER JOIN data2 b ON a.District = b.District) c
GROUP BY State;


--------------------------------------------------------------

-- Query 12: Total Population (Previous and Current) and Total Area
SELECT 
    d.Previous_population, d.Current_Population, f.Total_Area
FROM
    (SELECT 
        '1' AS keyy,
        SUM(Previous_census_population) Previous_population,
        SUM(Population) Current_Population
    FROM
        (SELECT 
            a.District,
            a.State,
            a.Growth,
            ROUND(b.Population / (1 + (growth / 100)), 0) Previous_census_population,
            b.Population
        FROM
            data1 a
        INNER JOIN data2 b ON a.District = b.District) c) d
INNER JOIN
    (SELECT 
        '1' AS keyy, SUM(Area_km2) AS Total_Area
    FROM
        data2) f ON d.keyy = f.keyy;


--------------------------------------------------------------

-- Query 13: Ratio of Total Area to Previous and Current Population
WITH CTE AS (
    SELECT 
        tb2.Previous_population, tb2.Current_Population , f.total_area
    FROM 
        (SELECT 
            '1' as keyy, 
            SUM(tb1.Previous_census_population) Previous_population, 
            SUM(tb1.pop) Current_Population
        FROM 
            (SELECT 
                a.District,a.State, 
                a.Growth, 
                ROUND(b.Population/(1 + (a.growth/100)),0) Previous_census_population, 
                b.Population AS pop
            FROM 
                data1 a
            INNER JOIN data2 b ON a.District = b.District) tb1) tb2 
    INNER JOIN 
        (SELECT 
            '1' as keyy, SUM

(Area_km2) as Total_area 
        FROM 
            data2) f ON tb2.keyy = f.keyy)
SELECT  
    ROUND(Total_area/Current_Population, 6)  areakm2_to_previous_population_ratio, 
    ROUND(Total_area/Previous_population,6) areakm2_to_current_population_ratio
FROM 
    CTE;


--------------------------------------------------------------

-- Query 14: Top 3 Districts from Each State with Highest Literacy Rate
SELECT 
    a.* 
FROM
    (SELECT 
        state,
        district,
        literacy,
        RANK() OVER(PARTITION BY state ORDER BY literacy DESC) rnk
    FROM 
        data1) a
WHERE 
    a.rnk IN (1,2,3) 
ORDER BY 
    state;