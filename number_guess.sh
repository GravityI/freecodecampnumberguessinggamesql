#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#Game Variables
RANDOM_NUMBER=$((1 + $RANDOM % 1000))
NUMBER_OF_GUESSES=0

USERNAME_MENU ()
{
  #Prompts the user for the username and tries to get existing data. After that, starts the game
  echo "Enter your username:"
  read USERNAME
  USERNAME_RESULT=$($PSQL "SELECT name FROM users WHERE name = '$USERNAME'")
  if [[ -z $USERNAME_RESULT ]]
  then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    GAMES_PLAYED=0
    NEW_PLAYER=true
  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USERNAME'")
    NEW_PLAYER=false
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
  ((GAMES_PLAYED++))
  GAME_MENU "Guess the secret number between 1 and 1000:"
}

GAME_MENU ()
{
  #Game functionality
  if [[ $1 ]]
  then
    echo -e "$1"
  fi

  read GUESS
  INTEGER_PATTERN='^[0-9]+$'
  if [[ $GUESS =~ $INTEGER_PATTERN ]]
  then
    ((NUMBER_OF_GUESSES++))
    if [[ "$GUESS" -gt "$RANDOM_NUMBER" ]]
    then  
      GAME_MENU "It's lower than that, guess again:"
    elif [[ "$GUESS" -lt "$RANDOM_NUMBER" ]]
    then
      GAME_MENU "It's higher than that, guess again:"
    else
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      #Save data
      if [[ $NEW_PLAYER == true ]]
      then
        BEST_GAME=$NUMBER_OF_GUESSES
        SAVE_RESULT=$($PSQL "INSERT INTO users (name, games_played, best_game) VALUES ('$USERNAME', $GAMES_PLAYED, $BEST_GAME)")
      else
        BEST_GAME=$(( $NUMBER_OF_GUESSES < $BEST_GAME ? $NUMBER_OF_GUESSES : $BEST_GAME ))
        SAVE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE name = '$USERNAME'")
      fi
    fi
  else
    GAME_MENU "That is not an integer, guess again:"
  fi
}

USERNAME_MENU