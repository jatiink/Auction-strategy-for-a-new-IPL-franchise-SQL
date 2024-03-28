CREATE TABLE matches (
    match_id INT,
    match_city VARCHAR(255),
    match_date DATE,
    player_of_the_match VARCHAR(255),
    match_venue VARCHAR(255),
    neutral_venue INT,
    team_1 VARCHAR(255),
    team_2 VARCHAR(255),
    toss_winner VARCHAR(255),
    toss_decision VARCHAR(255),
    match_winner VARCHAR(255),
    match_result VARCHAR(255),
    result_margin INT,
    eliminator VARCHAR(255),
    method VARCHAR(255),
    umpire_1 VARCHAR(255),
    umpire_2 VARCHAR(255)
);

COPY matches FROM 'D:\Internshala course\Projects\SQL\IPL_matches.csv' DELIMITER ',' CSV HEADER;

CREATE TABLE deliveries (
    match_id INT,
    inning INT,
    over INT,
    ball INT,
    batsman_name VARCHAR(255),
    non_striker VARCHAR(255),
    bowler VARCHAR(255),
    batsman_runs INT,
    extra_runs INT,
    total_runs INT,
    is_wicket INT,
    dismissal_kind VARCHAR(255),
    player_dismissed VARCHAR(255),
    fielder_name VARCHAR(255),
    extras_type VARCHAR(255),
    batting_team VARCHAR(255),
    bowling_team VARCHAR(255));

COPY deliveries FROM 'D:\Internshala course\Projects\SQL\IPL_ball.csv' DELIMITER ',' CSV HEADER;

---------------------------------------------------------------------------------------------------------
-------------------------------------------------TASK 1--------------------------------------------------
-- Get 2-3 players with high strike rates who have faced at least 500 balls--

SELECT batsman_name,
	SUM(batsman_runs) as total_runs,
	COUNT(ball) as balls_faced,
	ROUND(SUM(batsman_runs) * 1.0 / COUNT(ball), 2) as strike_rate
FROM deliveries
WHERE extras_type <> 'wides'
GROUP BY batsman_name
HAVING COUNT(ball)>=500
ORDER BY strike_rate DESC
LIMIT 10;

/* TOP 3 PLAYERS
1. AD Russell
2. SP Narine
3. HH Pandya */

---------------------------------------------------------------------------------------------------------
-------------------------------------------------TASK 2--------------------------------------------------
-- Get 2-3 players with good averages who have played more than 2 IPL seasons--

SELECT batsman_name,
	COUNT(DISTINCT EXTRACT(YEAR FROM matches.match_date)) AS seasons_played,
    SUM(batsman_runs) as total_runs,
	SUM(is_wicket) as dismissals,
	ROUND(SUM(batsman_runs) * 1.0 / SUM(is_wicket), 2) as batting_average
FROM deliveries
JOIN matches ON deliveries.match_id = matches.match_id
GROUP BY batsman_name
HAVING SUM(is_wicket) > 0 AND COUNT(DISTINCT EXTRACT(YEAR FROM matches.match_date)) > 2
ORDER BY batting_average DESC
LIMIT 10;

/* TOP 3 PLAYERS
1. Iqbal Abdulla
2. KL Rahul
3. AB de Villiers */

---------------------------------------------------------------------------------------------------------
-------------------------------------------------TASK 3--------------------------------------------------
-- Get 2-3 hard-hitting players with the most runs in boundaries and have played more than 2 IPL seasons--

SELECT batsman_name,
	COUNT(DISTINCT EXTRACT(YEAR FROM matches.match_date)) AS seasons_played,
	SUM(CASE WHEN batsman_runs = 4 THEN 4 WHEN batsman_runs = 6 THEN 6 ELSE 0 END) AS boundary_runs,
	SUM(batsman_runs) AS total_runs,
	ROUND(SUM(CASE WHEN batsman_runs = 4 THEN 4 WHEN batsman_runs = 6 THEN 6 ELSE 0 END) *100.0 / SUM(batsman_runs), 2) as boundary_percentage
FROM deliveries
JOIN matches ON deliveries.match_id = matches.match_id
GROUP BY batsman_name 
HAVING COUNT(DISTINCT EXTRACT(YEAR FROM matches.match_date)) > 2
ORDER BY boundary_percentage DESC
LIMIT 10;

/* TOP 3 PLAYERS
1. SP Narine
2. AD Russell
3. CH Gayle */

---------------------------------------------------------------------------------------------------------
-------------------------------------------------TASK 4--------------------------------------------------
-- Get 2-3 economical bowlers who have bowled at least 500 balls in IPL ---------------------------------

SELECT bowler,
    SUM(total_runs) AS total_runs_conceded,
	COUNT(ball) as total_balls_bowled,
	ROUND(sum(total_runs) / (COUNT(ball)/6.0), 2) as economy
FROM deliveries
GROUP BY bowler
HAVING COUNT(ball)>=500
ORDER BY economy
LIMIT 10;

/* TOP 3 PLAYERS
1. Rashid Khan
2. A Kumble
3. M Muralitharan */

---------------------------------------------------------------------------------------------------------
-------------------------------------------------TASK 5--------------------------------------------------
-- Get 2-3 wicket-taking bowlers with the best strike rate who have bowled at least 500 balls in IPL

SELECT bowler,
	COUNT(ball) as total_balls_bowled,
	SUM(is_wicket) as total_wickets_done,
	ROUND(COUNT(ball) * 1.0 / SUM(is_wicket), 2) as strike_rate
FROM deliveries
GROUP BY bowler
HAVING COUNT(ball)>=500
ORDER BY strike_rate DESC
LIMIT 10;

/* TOP 3 PLAYERS
1. SK Raina
2. NA Saini
3. CH Gayle */

---------------------------------------------------------------------------------------------------------
-------------------------------------------------TASK 6--------------------------------------------------
--Get 2-3 All_rounders with the best batting as well as bowling strike rate and who have faced at least 500 balls in IPL

SELECT
    bat.batsman_name as all_rounder,
    ROUND(bat.strike_rate, 2) AS batsman_strike_rate,
    ROUND(ball.strike_rate, 2) AS bowler_strike_rate
FROM
    (SELECT batsman_name,
	 	SUM(batsman_runs) * 1.0 / COUNT(ball) AS strike_rate
	 FROM deliveries
     WHERE extras_type <> 'wides'
     GROUP BY batsman_name
     HAVING COUNT(ball) >= 500) 
	 AS bat
JOIN (SELECT bowler,
	  	COUNT(ball) * 1.0 / SUM(is_wicket) AS strike_rate
	  FROM deliveries
      GROUP BY bowler
      HAVING COUNT(ball) >= 300)
	  AS ball
ON bat.batsman_name = ball.bowler
ORDER BY batsman_strike_rate DESC, bowler_strike_rate DESC
LIMIT 10;

/* TOP 3 PLAYERS
1. AD Russell
2. SP Narine
3. HH Pandya */

---------------------------------------------------------------------------------------------------------
-------------------------------------------------TASK 7--------------------------------------------------
-- WICKET KEEPER ----------------------------------------------------------------------------------------

SELECT d.fielder_name as wicketkeeper,
	COUNT(DISTINCT d.match_id) as Total_matches_played,
	COUNT(is_wicket) as wicket_count,
	ROUND(COUNT(is_wicket)*1.0/ COUNT(DISTINCT d.match_id), 2) as average_stumped
FROM Deliveries as d
JOIN matches ON d.match_id = matches.match_id
WHERE dismissal_kind ~* ('stumped')
GROUP BY fielder_name
HAVING COUNT(DISTINCT EXTRACT(YEAR FROM matches.match_date)) > 5
ORDER BY average_stumped DESC
LIMIT 2;

---------------------------------------------------------------------------------------------------------
--ADDITIONAL Question 1

SELECT COUNT(DISTINCT(match_city)) as count_of_cities
FROM matches;

---------------------------------------------------------------------------------------------------------
--ADDITIONAL Question 2

CREATE TABLE deliveries_v02 as SELECT *,
	CASE WHEN total_runs >= 4 THEN 'Boundary'
		 WHEN total_runs = 0 THEN 'Dot'
		 ELSE 'Other'
	END AS ball_result
from deliveries;

---------------------------------------------------------------------------------------------------------
--ADDITIONAL Question 3

SELECT ball_result,
COUNT(*)
FROM deliveries_v02
GROUP BY ball_result

---------------------------------------------------------------------------------------------------------
--ADDITIONAL Question 4

SELECT batting_team,
	COUNT(ball_result) as boundaries
FROM deliveries_v02
WHERE ball_result = 'Boundary'
GROUP BY batting_team
ORDER BY boundaries DESC;

---------------------------------------------------------------------------------------------------------
--ADDITIONAL Question 5

SELECT bowling_team,
	COUNT(ball_result) as Dots
FROM deliveries_v02
WHERE ball_result = 'Dot'
GROUP BY bowling_team
ORDER BY Dots DESC;

---------------------------------------------------------------------------------------------------------
--ADDITIONAL Question 6

SELECT dismissal_kind,
	COUNT(*) as total_dismissals
FROM deliveries_v02
WHERE dismissal_kind <> 'NA'
GROUP BY dismissal_kind;

---------------------------------------------------------------------------------------------------------
--ADDITIONAL Question 7

SELECT bowler,
	SUM(extra_runs) as Total_extra_runs
FROM deliveries
GROUP BY bowler
ORDER BY Total_extra_runs DESC
LIMIT 5;

---------------------------------------------------------------------------------------------------------
--ADDITIONAL Question 8

CREATE TABLE deliveries_v03 as
SELECT dv02.*, m.match_venue as venue, m.match_date as match_date
FROM deliveries_v02 as dv02
JOIN (SELECT match_id, match_venue, match_date FROM matches) as m ON dv02.match_id = m.match_id;

---------------------------------------------------------------------------------------------------------
--ADDITIONAL Question 9

SELECT venue,
SUM(batsman_runs) as total_runs_scored
FROM deliveries_v03
GROUP BY venue
ORDER BY total_runs_scored DESC;

---------------------------------------------------------------------------------------------------------
--ADDITIONAL Question 9

SELECT EXTRACT(YEAR FROM match_date) as year,
	SUM(batsman_runs) as total_runs
FROM deliveries_v03
WHERE venue ~*('eden gardens')
GROUP BY year
ORDER BY total_runs DESC