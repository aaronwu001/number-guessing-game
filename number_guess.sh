#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_TARGET=$(( $RANDOM % 1000 + 1 ))


echo "Enter your username:"
read USER_NAME

# get user id by name
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")

# say hi and insert users
if [[ $USER_ID ]]
then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id=$USER_ID")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER_ID")
  echo "Welcome back, $USER_NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USER_NAME! It looks like this is your first time here."
  USER_INSERT_RESULT=$($PSQL "INSERT INTO users(name) VALUES('$USER_NAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USER_NAME'")
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

GUESS_COUNTER=1
until [[ $GUESS == $RANDOM_TARGET ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $(( GUESS )) -lt $RANDOM_TARGET ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
  fi
  
  read GUESS
  (( GUESS_COUNTER++ ))
done

# update games_played
(( UPDATED_GAMES_PLAYED = GAMES_PLAYED + 1 ))
GAMES_PLAYED_UPDATE_RESULT=$($PSQL "UPDATE users SET games_played=$UPDATED_GAMES_PLAYED WHERE user_id=$USER_ID")

# update best_game
if [[ -z $BEST_GAME ]]
then
  BEST_GAME_UPDATE_RESULT=$($PSQL "UPDATE users SET best_game=$GUESS_COUNTER WHERE user_id=$USER_ID")
else
  if [[ $GUESS_COUNTER -lt $BEST_GAME ]]
  then
    BEST_GAME_UPDATE_RESULT=$($PSQL "UPDATE users SET best_game=$GUESS_COUNTER WHERE user_id=$USER_ID")
  fi
fi

echo "You guessed it in $GUESS_COUNTER tries. The secret number was $RANDOM_TARGET. Nice job!"
