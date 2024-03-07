#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" && $ROUND != "Round" && $WINNER != "Winner" && $OPPONENT != "Opponent" && $WINNER_GOALS != "winner_goals" && $OPPONENT_GOALS != "opponent_goals" ]]
  then

    # Check if team exists in teams table
    WINNER_CHECK=$($PSQL "SELECT name FROM teams WHERE name='$WINNER';")
    OPPONENT_CHECK=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT';")

    # If not, add the team to the teams table
    if [[ -z $WINNER_CHECK ]]
    then
      INSERT_WINNER=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER');")
      if [[ $INSERT_WINNER == "INSERT 0 1" ]]
      then
        echo Inserted: $WINNER
      else
        echo $WINNER already in table.
      fi
    fi
    if [[ -z $OPPONENT_CHECK ]]
    then
      INSERT_OPPONENT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT');")
      if [[ $INSERT_OPPONENT == "INSERT 0 1" ]]
      then
        echo Inserted: $OPPONENT
      else
        echo $OPPONENT already in table.
      fi
    fi

    # Insert each game into games table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
      if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo Game added.
    else
      echo Error, game not added.
    fi
  fi
done
