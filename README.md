# NBA Historical Performance Analysis

## Overview

This project analyzes NBA historical performance from **1946–2023** using SQL, Python, and Tableau.

The analysis focuses on franchise performance, scoring trends, winning streaks, home-court advantage, and NBA Draft outcomes. The goal is to transform historical NBA game and player data into clear, data-driven insights that support performance analysis and decision-making.

## Business Questions

The analysis answers seven key questions:

1. Which NBA franchises have the most all-time wins?
2. How has NBA scoring changed across decades?
3. Which NBA franchises have the highest average points per game?
4. What are the longest winning streaks in NBA history?
5. How did the 1971–72 Los Angeles Lakers perform throughout their historic season?
6. Which franchises have benefited most from home-court advantage?
7. How successful are NBA Draft picks across different draft rounds?

## Dataset

The project uses the **Kaggle NBA database**, containing historical NBA game, team, player, and draft information.

The database covers NBA history from **1946 through 2023** and includes tables related to:

* Games
* Teams
* Players
* Draft history
* Player information
* Game statistics
* Team information

For the analysis, relevant SQL queries were used to extract and transform the required datasets, which were then exported as CSV files for visualization in Tableau.

## Tools & Technologies

* **SQL / SQLite** — data extraction, transformation, aggregation, and analysis
* **Python** — data processing and analysis
* **Pandas** — data manipulation
* **Matplotlib** — exploratory visualization
* **Tableau Public** — interactive dashboard development
* **Jupyter Notebook** — analysis workflow
* **GitHub** — project documentation and version control

## Data Processing

The analysis involved:

* Extracting historical game and player data using SQL
* Separating regular-season and playoff performance
* Consolidating NBA team identities at the franchise level where appropriate
* Calculating franchise win totals
* Calculating average scoring by decade
* Calculating franchise-level scoring averages
* Identifying historical winning streaks using SQL window functions
* Calculating a 5-game rolling scoring average for the 1971–72 Los Angeles Lakers
* Measuring home versus away win percentages
* Analyzing NBA Draft outcomes by draft round
* Exporting analysis results into CSV files for Tableau visualization

### Franchise vs. Team-Era Analysis

Different questions require different levels of analysis.

Franchise-level analysis was used for questions involving long-term franchise performance, including wins, scoring averages, and home-court advantage. Historical franchise identities were consolidated using team IDs to account for relocations and name changes.

Winning streak analysis was kept at the team-era level because a winning streak belongs to a specific team season rather than the entire history of a franchise.

## Key Insights

### 1. All-Time Franchise Wins

The Los Angeles Lakers rank first in this dataset when regular-season and playoff wins are combined.

| Franchise          | Regular Season Wins | Playoff Wins | Combined Wins |
| ------------------ | ------------------: | -----------: | ------------: |
| Los Angeles Lakers |               3,193 |          402 |         3,595 |
| Boston Celtics     |               3,210 |          356 |         3,566 |

The ranking changes depending on whether regular-season wins, playoff wins, or combined wins are used. This highlights the importance of clearly defining the metric when comparing historical franchise performance.

### 2. NBA Scoring Has Changed Dramatically

Average total points per game increased substantially from the early decades of NBA history.

The highest average scoring decade in this dataset is the **1960s**, at approximately **227.9 total points per game**.

The 1990s and 2000s show noticeably lower scoring levels before scoring increased again in the 2010s and 2020s.

### 3. Highest Franchise Scoring Averages

The Phoenix Suns have the highest average points per game among franchises meeting the minimum games-played threshold, averaging approximately **107.8 points per game**.

The Denver Nuggets and Los Angeles Lakers follow with approximately **107.6** and **105.7** points per game, respectively.

### 4. Longest Winning Streak

The longest winning streak identified in the analysis belongs to the **1971–72 Los Angeles Lakers**, who won **33 consecutive games**.

This streak occurred during one of the most successful regular seasons in NBA history.

### 5. 1971–72 Lakers Scoring Trend

A **5-game rolling average** was used to examine how the Lakers' scoring changed throughout their 1971–72 season.

The rolling average helps smooth individual game fluctuations and provides a clearer view of scoring trends across the season.

### 6. Home-Court Advantage

The Atlanta Hawks recorded the largest home-versus-away win percentage difference among franchises meeting the minimum games-played threshold.

Their home win percentage was approximately **64.8%**, compared with **34.9%** away from home, producing a **29.9 percentage-point home-court advantage**.

### 7. NBA Draft Outcomes

First-round selections had substantially higher NBA appearance rates than later-round selections.

* **First Round:** 73.4% appeared in the NBA
* **Later Rounds:** 22.3% appeared in the NBA

This demonstrates the strong relationship between draft position and the likelihood of reaching an NBA game.

## Tableau Dashboard

The interactive dashboard brings together all seven analyses in a single view.

**View the interactive Tableau dashboard:**

[Tableau Public Dashboard](https://public.tableau.com/app/profile/hazeezat.adebimpe.adebayo/viz/NBAHistoricalAnalysis/Dashboard1)

## Project Structure

```text
NBA-Historical-Performance-Analysis/
│
├── NBA_Historical_Analysis.ipynb
├── nba_analysis.sql
├── README.md
│
├── q1_franchise_wins.csv
├── q1_top2_comparison.csv
├── q2_scoring_by_decade.csv
├── q3_franchise_scoring_avg.csv
├── q4_win_streaks.csv
├── q5_lakers_rolling_avg.csv
├── q6_home_advantage.csv
├── q7_draft_outcomes.csv
└── summary_stats.csv
```

## Limitations

This analysis has several limitations that should be considered when interpreting the results:

* **Historical cutoff:** The underlying dataset ends in **2023**, so the analysis does not include the most recent NBA seasons.

* **Uneven sample sizes across decades:** The 1940s and 2020s contain fewer games than complete decades. Therefore, comparisons across decades should be interpreted with sample size in mind.

* **Franchise win definitions:** Historical franchise win totals can vary between sources depending on how franchise history, early league games, relocations, and playoff games are defined and counted.

* **Draft success measurement:** Draft success is measured by whether a player appears in an NBA game based on the available player information. It does not measure career length, player performance, awards, or All-Star-level success.

* **Dataset dependency:** The analysis is based on the structure, definitions, and completeness of the underlying Kaggle NBA database. Any missing or inconsistently recorded historical data may affect the results.

## Key Takeaway

NBA historical performance varies significantly depending on the metric used.

The analysis demonstrates how **SQL can be used to transform large historical datasets into meaningful performance metrics**, while **Tableau makes those insights accessible through interactive visualizations**.

The project also highlights the importance of defining metrics carefully when working with historical sports data, particularly when comparing franchises across different eras.

## Author

**Hazeezat Adebayo**

Data Analyst | SQL | Python | Tableau | Data Visualization
