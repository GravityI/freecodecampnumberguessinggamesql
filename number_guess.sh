#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$((1 + $RANDOM % 1000))
NUMBER_OF_GUESSES=0
echo $RANDOM_NUMBER

USERNAME_MENU ()
{
  #Prompts the user for the username and either gets existing data or adds
  echo "Enter your username:"
  read USERNAME
  USERNAME_RESULT=$($PSQL "SELECT name FROM users WHERE name = '$USERNAME'")
  if [[ -z $USERNAME_RESULT ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  GAME_MENU "Guess the secret number between 1 and 1000:"
}

GAME_MENU ()
{
  ((NUMBER_OF_GUESSES++))
  if [[ $1 ]]
  then
    echo -e "$1"
  fi
  read GUESS
  INTEGER_PATTERN='^[0-9]+$'
  if [[ $GUESS =~ $INTEGER_PATTERN ]]
  then
    if [[ "$GUESS" -gt "$RANDOM_NUMBER" ]]
    then  
      GAME_MENU "It's lower than that, guess again:"
    elif [[ "$GUESS" -lt "$RANDOM_NUMBER" ]]
    then
      GAME_MENU "It's higher than that, guess again:"
    else
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
    fi
  else
    GAME_MENU "That is not an integer, guess again:"
  fi
}

USERNAME_MENU