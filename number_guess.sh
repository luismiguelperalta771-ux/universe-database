#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$((RANDOM % 1000 + 1))
GUESSES=0

echo "Enter your username:"
read USERNAME

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")

if [[ -z $GAMES_PLAYED ]]
then
  $PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)" > /dev/null
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  if ! [[ $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  GUESSES=$((GUESSES + 1))

  if [[ $GUESS -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    GAMES=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
    BEST=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
    NEW_GAMES=$((GAMES + 1))

    if [[ -z $BEST ]] || [[ $GUESSES -lt $BEST ]]
    then
      $PSQL "UPDATE users SET games_played=$NEW_GAMES, best_game=$GUESSES WHERE username='$USERNAME'" > /dev/null
    else
      $PSQL "UPDATE users SET games_played=$NEW_GAMES WHERE username='$USERNAME'" > /dev/null
    fi

    break
  fi
done
