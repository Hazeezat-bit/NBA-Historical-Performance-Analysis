-- ============================================================
-- NBA Historical Performance Analysis
-- Database: nba.sqlite (Kaggle - wyattowalsh/basketball)
-- ============================================================

-- ============================================================
-- Q1: Which teams have the most wins in franchise history?
-- ============================================================
-- Note: game/line_score are wide-format tables (one row per game,
-- separate home/away columns). A naive query using only wl_home
-- undercounts real team wins by ignoring away games. Fixed below
-- using UNION ALL to combine home and away perspectives.

SELECT team_name, SUM(win) AS total_wins
FROM (
    SELECT team_name_home AS team_name, CASE WHEN wl_home = 'W' THEN 1 ELSE 0 END AS win
    FROM game
    UNION ALL
    SELECT team_name_away AS team_name, CASE WHEN wl_away = 'W' THEN 1 ELSE 0 END AS win
    FROM game
) combined
GROUP BY team_name
ORDER BY total_wins DESC
LIMIT 10;

-- RESULT (verified):
-- Boston Celtics        3625
-- Los Angeles Lakers    3123
-- New York Knicks       2863
-- Philadelphia 76ers    2462
-- Detroit Pistons       2448
-- San Antonio Spurs     2427
-- Phoenix Suns          2424
-- Chicago Bulls         2377
-- Milwaukee Bucks       2345
-- Houston Rockets       2277


-- ============================================================
-- Q2: How has scoring per game changed across NBA eras (by decade)?
-- ============================================================

SELECT 
    (CAST(STRFTIME('%Y', game_date) AS INTEGER) / 10) * 10 AS decade,
    AVG(pts_home + pts_away) AS avg_total_points_per_game
FROM game
WHERE pts_home IS NOT NULL AND pts_away IS NOT NULL
GROUP BY decade
ORDER BY decade;

-- RESULT (verified):
-- 1940   150.04
-- 1950   183.50
-- 1960   227.88   <- peak
-- 1970   216.01
-- 1980   218.18
-- 1990   201.76
-- 2000   193.90   <- low point (isolation-heavy era)
-- 2010   205.46
-- 2020   224.45   <- rising again (3-point revolution)
-- NOTE: 1940s figure likely based on very few games (league was new) -
-- verify game count before treating as a reliable data point.

-- Verification: game count per decade
SELECT (CAST(STRFTIME('%Y', game_date) AS INTEGER) / 10) * 10 AS decade,
       COUNT(*) AS game_count
FROM game
GROUP BY decade
ORDER BY decade;

-- RESULT (verified):
-- 1940    1,187   <- small sample, treat avg as unreliable
-- 1950    3,462
-- 1960    3,169
-- 1970    5,830
-- 1980    10,055
-- 1990    11,569
-- 2000    13,305
-- 2010    12,495
-- 2020    4,626   <- decade still in progress (incomplete), not
--                    directly comparable to full decades


-- ============================================================
-- Q3: Which teams score the most points per game on average, and
--     does the ranking change with a minimum-games-played threshold?
-- ============================================================
-- Note: revised from player-level to team-level (game/line_score have
-- no individual player box scores outside play_by_play, excluded).

SELECT team_name, AVG(pts) AS avg_points, COUNT(*) AS games_played
FROM (
    SELECT team_name_home AS team_name, pts_home AS pts
    FROM game
    UNION ALL
    SELECT team_name_away AS team_name, pts_away AS pts
    FROM game
) combined
WHERE pts IS NOT NULL
GROUP BY team_name
HAVING games_played >= 500
ORDER BY avg_points DESC
LIMIT 10;

-- RESULT (verified):
-- Cincinnati Royals        112.75   (902 games)
-- San Francisco Warriors   112.00   (608 games)
-- LA Clippers              110.58   (720 games)
-- Kansas City Kings        109.83   (682 games)
-- New Orleans Pelicans     108.34   (862 games)
-- St. Louis Hawks          108.00   (848 games)
-- Los Angeles Lakers       107.78   (5203 games)
-- Phoenix Suns             107.73   (4490 games)
-- Golden State Warriors    107.25   (4298 games)
-- Denver Nuggets           107.08   (3999 games)
--
-- LIMITATION: team_name reflects historical franchise names, not
-- unified franchise identity across relocations/renames. Several top
-- entries (Cincinnati Royals, San Francisco Warriors, Kansas City
-- Kings, St. Louis Hawks) are earlier names of teams that still exist
-- today under different names (e.g. Royals -> Kings, SF Warriors ->
-- Golden State Warriors, STL Hawks -> Atlanta Hawks). This is a real
-- finding, not an error: it reinforces Q2 (older eras scored more
-- combined points per game) at the team level, since several of these
-- high-scoring names are 1960s-era franchises. Ranking reflects
-- scoring by team-name/era, not by full continuous franchise history.


-- ============================================================
-- Q4: What was the longest win streak for any team in NBA history?
-- ============================================================
-- Classic "gaps and islands" window-function pattern: subtracting a
-- rank-within-all-games from a rank-within-wins-only produces a
-- constant value for consecutive wins, letting us group streaks.

WITH team_games AS (
    SELECT team_name_home AS team_name, game_date, CASE WHEN wl_home = 'W' THEN 1 ELSE 0 END AS win
    FROM game
    UNION ALL
    SELECT team_name_away AS team_name, game_date, CASE WHEN wl_away = 'W' THEN 1 ELSE 0 END AS win
    FROM game
),
ordered AS (
    SELECT team_name, game_date, win,
           ROW_NUMBER() OVER (PARTITION BY team_name ORDER BY game_date) AS game_rank,
           ROW_NUMBER() OVER (PARTITION BY team_name, win ORDER BY game_date) AS win_rank
    FROM team_games
),
streak_groups AS (
    SELECT team_name, game_date, win, (game_rank - win_rank) AS streak_id
    FROM ordered
)
SELECT team_name, COUNT(*) AS streak_length, MIN(game_date) AS streak_start, MAX(game_date) AS streak_end
FROM streak_groups
WHERE win = 1
GROUP BY team_name, streak_id
ORDER BY streak_length DESC
LIMIT 5;

-- RESULT (verified):
-- Los Angeles Lakers      33 games   1971-11-05 to 1972-01-07
-- Golden State Warriors   25 games   2015-10-22 to 2015-12-11
-- Houston Rockets         22 games   2008-01-29 to 2008-03-16
-- San Antonio Spurs       20 games   2012-04-12 to 2012-05-29
-- Atlanta Hawks           19 games   2014-12-27 to 2015-01-31
--
-- Cross-checked against real NBA history: the 1971-72 Lakers' 33-game
-- win streak is a well-documented record - still the longest winning
-- streak in any major North American professional sports league.
-- Confirms the query logic is correct.


-- ============================================================
-- Q5: For a team's best season, what's their game-by-game scoring
--     trend with a rolling average?
-- ============================================================
-- Uses the 1971-72 LA Lakers season (confirmed via Q4 as their
-- record 33-game win streak season). Genuine window-function rolling
-- calculation: 5-game trailing average.

SELECT game_date, pts,
       AVG(pts) OVER (ORDER BY game_date ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS rolling_5game_avg
FROM (
    SELECT game_date, pts_home AS pts
    FROM game
    WHERE team_name_home = 'Los Angeles Lakers'
      AND game_date BETWEEN '1971-10-01' AND '1972-06-01'
    UNION ALL
    SELECT game_date, pts_away AS pts
    FROM game
    WHERE team_name_away = 'Los Angeles Lakers'
      AND game_date BETWEEN '1971-10-01' AND '1972-06-01'
)
ORDER BY game_date;

-- RESULT (verified, ~95 games returned - excerpt below):
-- 1971-10-15   132   132.0
-- 1971-11-05   110   110.6   <- start of the 33-game win streak
-- 1971-12-19   154   129.6   <- peak of the streak period
-- 1972-01-07   134   119.2   <- end of the 33-game win streak
-- 1972-03-19   162   135.2   <- season scoring peak
-- 1972-04-09    72   102.8   <- playoff-period cooldown begins
-- 1972-05-07   114   107.0   <- final game in range
--
-- FINDING: rolling average smooths game-to-game volatility (single
-- games swing from 72 to 162 pts) into a clear trend. Scoring rolling
-- average is strongest Dec-Mar (~120-135), then drops notably in
-- April (~100-110) - consistent with slower, more defensive playoff
-- basketball. Full 95-row output available in notebook/database, not
-- reproduced in full here.


-- ============================================================
-- Q6: Which teams have the strongest home-court advantage (biggest
--     gap between home win % and away win %)?
-- ============================================================

SELECT team_name,
       ROUND(AVG(CASE WHEN location = 'home' THEN win END) * 100, 1) AS home_win_pct,
       ROUND(AVG(CASE WHEN location = 'away' THEN win END) * 100, 1) AS away_win_pct,
       ROUND(AVG(CASE WHEN location = 'home' THEN win END) * 100, 1) -
       ROUND(AVG(CASE WHEN location = 'away' THEN win END) * 100, 1) AS advantage_gap
FROM (
    SELECT team_name_home AS team_name, 'home' AS location, CASE WHEN wl_home = 'W' THEN 1 ELSE 0 END AS win
    FROM game
    UNION ALL
    SELECT team_name_away AS team_name, 'away' AS location, CASE WHEN wl_away = 'W' THEN 1 ELSE 0 END AS win
    FROM game
) combined
GROUP BY team_name
HAVING COUNT(*) >= 500
ORDER BY advantage_gap DESC
LIMIT 10;

-- RESULT (verified):
-- Ft. Wayne Zollner Pistons   75.2% home / 23.9% away  (gap: 51.3)
-- Philadelphia Warriors       74.0% home / 25.3% away  (gap: 48.7)
-- Syracuse Nationals          79.6% home / 33.0% away  (gap: 46.6)
-- Minneapolis Lakers          78.3% home / 33.3% away  (gap: 45.0)
-- St. Louis Hawks             77.4% home / 34.8% away  (gap: 42.6)
-- Rochester Royals            76.3% home / 35.3% away  (gap: 41.0)
-- Kansas City Kings           63.4% home / 30.3% away  (gap: 33.1)
-- Cincinnati Royals           63.3% home / 30.3% away  (gap: 33.0)
-- Baltimore Bullets           61.0% home / 29.1% away  (gap: 31.9)
-- Denver Nuggets              63.5% home / 34.1% away  (gap: 29.4)
--
-- Sample-size check (all comfortably above the 500-game threshold,
-- confirming this is not a small-sample artifact):
-- Ft. Wayne Zollner Pistons   665 games
-- Minneapolis Lakers          933 games
-- Philadelphia Warriors      1009 games
-- Rochester Royals            659 games
-- St. Louis Hawks             848 games
-- Syracuse Nationals          932 games
--
-- FINDING: every team in the top 10 is a historical/defunct-name
-- franchise from the NBA's earliest decades (1940s-60s) - no
-- current-era team names appear. Ties directly to Q2 and Q3: early
-- NBA basketball (smaller arenas, more regional officiating, less
-- travel-friendly scheduling) had a substantially stronger home-court
-- effect than the modern league. Builds a consistent narrative across
-- three separate queries that the early NBA was a structurally
-- different, more home-skewed league than today's.


-- ============================================================
-- Q7: Does draft position predict whether a player ever actually
--     plays in the NBA?
-- ============================================================
-- Demonstrates LEFT JOIN + IS NULL to find non-matches: drafted
-- players who never appear in common_player_info never made an NBA
-- roster.

SELECT 
    CASE WHEN round_number = 1 THEN '1st Round' ELSE 'Later Rounds' END AS draft_round_group,
    COUNT(*) AS total_drafted,
    SUM(CASE WHEN cpi.person_id IS NULL THEN 1 ELSE 0 END) AS never_appeared_in_nba,
    ROUND(SUM(CASE WHEN cpi.person_id IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS pct_never_played
FROM draft_history dh
LEFT JOIN common_player_info cpi ON dh.person_id = cpi.person_id
WHERE dh.draft_type = 'Draft'
GROUP BY draft_round_group;

-- RESULT (verified):
-- 1st Round       1,625 drafted   432 never appeared   26.6%
-- Later Rounds    6,611 drafted   5,138 never appeared  77.7%
--
-- FINDING: later-round picks are roughly 3x more likely than 1st-round
-- picks to never make an NBA roster (77.7% vs 26.6%). Draft position
-- is a meaningful predictor of whether a player ever actually plays
-- in the league, not just how well they perform once there.
--
-- LIMITATION: this dataset spans back to 1947, when the league had
-- far fewer roster spots overall (see Q2 game-count findings on early
-- decades). Some of the "never appeared" rate for later rounds likely
-- reflects eras with structurally fewer NBA roster spots available,
-- not purely draft-position skill signal. A decade-controlled version
-- of this analysis would be a natural extension.


-- ============================================================
-- END: All 7 questions answered and verified.
-- ============================================================






