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

SELECT playerid, namefirst, namelast,po, 
		CASE WHEN pos= 'OF' THEN 'Outfield'
			 WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			 WHEN pos IN ('P', 'C') THEN 'Battery'
			 END AS position_labels
FROM people 
LEFT JOIN fielding
USING (playerid)
WHERE yearid=2016
GROUP BY playerid, namefirst, namelast,po, position_labels
ORDER BY po DESC



WITH people AS (SELECT playerid, namefirst, namelast
				FROM people),
				
positions AS (SELECT playerid,
			  CASE WHEN pos= 'OF' THEN 'Outfield'
			 WHEN pos IN ('SS', '1B', '2B', '3B') THEN 'Infield'
			 WHEN pos IN ('P', 'C') THEN 'Battery'
			 END AS position_labels
			 FROM fielding 
			 )

			
				
				
				






/*3. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
Do the same for home runs per game. Do you see any trends? (Hint: For this question, you might find it helpful to look at 
the **generate_series** function (https://www.postgresql.org/docs/9.1/functions-srf.html). 
If you want to see an example of this in action, check out this DataCamp video: 
https://campus.datacamp.com/courses/exploratory-data-analysis-in-sql/summarizing-and-aggregating-numeric-data?ex=6)*/

SELECT *
FROM homegames 

SELECT *
FROM batting

SELECT *
FROM pitching

SELECT *
FROM awardsplayers


/*4. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen 
base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) 
Consider only players who attempted _at least_ 20 stolen bases. Report the players' names, number of stolen bases, number of attempts, and stolen base percentage.