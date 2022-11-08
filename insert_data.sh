#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WGOAL OGOAL
do
  if [[  $YEAR != "year"  ]]
  then
    # get team_id
    TEAM_IDW="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"

    # if not found
    if [[  -z $TEAM_IDW  ]]
    then
      # insert team
      INSERT_TEAMW_RESULT="$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")"
      if [[  $INSERT_TEAMW_RESULT == "INSERT 0 1"  ]]
      then
        echo Inserted into team, $WINNER
      fi
      # get new team id
      TEAM_IDW="$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")"
    fi
    
    # get_team_id for OPPONENT
    TEAM_IDO="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"

    # if not found
    if [[  -z $TEAM_IDO  ]]
    then
      # insert team
      INSERT_TEAMO_RESULT="$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")"
      if [[  $INSERT_TEAMO_RESULT == "INSERT 0 1"  ]]
      then
        echo Inserted into team, $OPPONENT
      fi
      # get new team id
      TEAM_IDO="$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")"
    fi

    # insert games
    INSERT_GAMES_RESULT="$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES ($YEAR, '$ROUND', $TEAM_IDW, $TEAM_IDO, $WGOAL, $OGOAL)")"
    if [[  $INSERT_GAMES_RESULT == "INSERT 0 1"  ]]
    then
      echo Inserted into games, $YEAR, $ROUND, $TEAM_IDW, $TEAM_IDO
    fi
  fi
done
