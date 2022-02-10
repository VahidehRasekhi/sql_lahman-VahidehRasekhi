/*1. Find all players in the database who played at Vanderbilt University. Create a list showing each player's first and last names 
as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. 
Which Vanderbilt player earned the most money in the majors?*/

--David Price earned the most money 
SELECT playerid, namefirst, namelast, SUM(salary) AS total_salary, schoolname
FROM people 
INNER JOIN salaries
USING (playerid)
LEFT JOIN collegeplaying 
USING (playerid)
LEFT JOIN schools
USING (schoolid)
WHERE schoolname='Vanderbilt University'
GROUP BY playerid, namefirst, namelast, schoolname
ORDER BY total_salary DESC;


/*2. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield",
those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". 
Determine the number of putouts made by each of these three groups in 2016.*/
---Order of outputs: Battery>infield>outfield
SELECT 
		CASE WHEN pos= 'OF' THEN 'Outfield'
			 WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			 WHEN pos IN ('P', 'C') THEN 'Battery'
			 END AS position_labels,
			 COUNT (po) AS number_of_putouts  ---QUESTION: why replacing 'count' with 'sum' changes the result? 
FROM fielding
WHERE yearid=2016
GROUP BY position_labels



/*3. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends? (Hint: For this question, you might find it helpful to look at 
the **generate_series** function (https://www.postgresql.org/docs/9.1/functions-srf.html). 
If you want to see an example of this in action, check out this DataCamp video: 
https://campus.datacamp.com/courses/exploratory-data-analysis-in-sql/summarizing-and-aggregating-numeric-data?ex=6)*/

--strikeouts
WITH decades AS (
SELECT
	generate_series(1920,2020, 10) AS decade)


SELECT 
	decade,
	Round(AVG(so)) AS avg_strikeout 
FROM decades
INNER JOIN teams 
ON yearID=decade
WHERE yearID>1920
GROUP BY decade
ORDER BY decade DESC


--homeruns
WITH decades AS (
SELECT
	generate_series(1920,2020, 10) AS decade)


SELECT 
	decade,
	Round(AVG(hr)) AS avg_homeruns 
FROM decades
INNER JOIN teams 
ON yearID=decade
WHERE yearID>1920
GROUP BY decade
ORDER BY decade DESC

--both strikeouts and homeruns have been increasing over the years, 


/*4. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen 
base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted _at least_ 20 stolen bases. Report the players' names, number of stolen bases, 
number of attempts, and stolen base percentage.*/

--Chris Owings has the most success rate stealing bases  in 2016
SELECT 
	   namefirst||' '|| namelast AS playername, 
	   sb AS stolen_bases, 
	   cs AS stolen_attemps,
	   ROUND (sb*100/(sb+cs), 2) AS stolen_base_percentage  
FROM batting
INNER JOIN people
USING (playerid)
WHERE yearid=2016
AND sb+cs>20
ORDER BY stolen_base_percentage  DESC
LIMIT 20


/* 5. From 1970 to 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest 
number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for 
a world series champion; determine why this is the case. Then redo your query, excluding the problem year. */

--116 is the largest number of wins for a team (Seattle Mariners) that didn't win world series 
WITH over_years AS (
SELECT
	generate_series(1970,2016, 1) AS over_the_years)
	
SELECT name, over_the_years, w AS number_of_wins, wswin AS world_series_winner
FROM over_years
LEFT JOIN teams 
ON yearID=over_the_years 
where wswin='N'
ORDER BY number_of_wins DESC


--63 is the smallest number of wins for a team (Los Angeles Dodgers) that did win world series
WITH over_years AS (
SELECT
	generate_series(1970,2016, 1) AS over_the_years)
	
SELECT name, over_the_years, w AS number_of_wins, wswin AS world_series_winner
FROM over_years
LEFT JOIN teams 
ON yearID=over_the_years 
where wswin='Y'
ORDER BY number_of_wins 

--How often from 1970 to 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?*/
WITH wins AS (
	SELECT yearid, name, w AS number_of_wins
	FROM teams 
	WHERE yearid between 1970 and 2016 
	AND wswin ='Y'
	ORDER BY number_of_wins DESC
),
	
max_wins AS (
	SELECT yearid, name, MAX(w) AS max_wins
	FROM teams
	WHERE yearid between 1970 and 2016 
	GROUP BY yearid, name
	ORDER BY max_wins DESC
)

--need to add percentage to the code below

SELECT 
	yearid, 
	CASE WHEN number_of_wins = max_wins THEN 1   
	ELSE 0
	END AS winners
FROM wins
INNER JOIN max_wins
USING (yearid) 
ORDER BY winners DESC 



/* 6. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
Give their full name and the teams that they were managing when they won the award.*/

WITH TSN_awards AS (
	(SELECT playerid
	FROM awardsmanagers
	WHERE awardid= 'TSN Manager of the Year'
	AND lgid='NL')
INTERSECt
	(SELECT playerid
	FROM awardsmanagers
	WHERE awardid= 'TSN Manager of the Year'
	AND lgid='AL')
	)
SELECT yearid, awardid, awardsmanagers.lgid, teamid, namefirst ||'  '|| namelast AS manager_name
FROM awardsmanagers 
INNER JOIN TSN_awards
USING (playerid)
LEFT JOIN people
USING (playerid)
LEFT JOIN managers
USING (playerid, yearid)
WHERE awardid= 'TSN Manager of the Year'
ORDER BY yearid
	
	
/* 7. Which pitcher was the least efficient in 2016 in terms of salary / strikeouts? Only consider pitchers who started at least 10 
games (across all teams). Note that pitchers often play for more than one team in a season, so be sure that you are counting all 
stats for each player.*/

SELECT namefirst||' ' ||namelast AS name, 
		(MAX(salary)/SUM(so))::numeric::money AS salary_per_so
FROM pitching 
INNER JOIN people
USING (playerid)
INNER JOIN salaries
USING (playerid, yearid)
WHERE yearid= 2016 
GROUP BY namefirst, namelast, playerid
HAVING sum (gs)>=10
ORDER BY salary_per_so DESC


/* 8. Find all players who have had at least 3000 career hits. Report those players' names, total number of hits, 
and the year they were inducted into the hall of fame (If they were not inducted into the hall of fame, put a null in that column.) 
Note that a player being inducted into the hall of fame is indicated by a 'Y' in the inducted column of the halloffame table.*/






--9. Find all players who had at least 1,000 hits for two different teams. Report those players' full names.

/* 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the 
league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number 
of home runs they hit in 2016.*/




	
	

