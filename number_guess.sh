#!/bin/bash

#number guessing game where random number is generated
#user guesses number and get hints until guess is correct

#CREATED BY DAVID FORBES, 2/27/2023

PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --tuples-only --no-align -c"

#generate random number between 1 and 1000
SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

#prompt user for username
echo "Enter your username:"
read USERNAME

SEARCH_USERNAME=$($PSQL "SELECT username FROM players WHERE username = '$USERNAME'")

#if username not found
if [[ -z $SEARCH_USERNAME ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

  #save username into database
  SAVE_USERNAME=$($PSQL "INSERT INTO players(username, games_played) VALUES('$USERNAME', 0)")

#if found
else

  GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

fi

#prompt user to guess number
echo -e "\nGuess the secret number between 1 and 1000:"

#counter to keep track of number of guesses
NUMBER_OF_GUESSES=0

#loop continues  until user correctly guesses secret number
while [[ $NUMBER_GUESS != $SECRET_NUMBER ]]
do
  
  read NUMBER_GUESS

  #if input is not a number
  if [[ ! $NUMBER_GUESS =~ ^[0-9]+$ ]]
  then
    echo -e "\nThat is not an integer, guess again:"
  

  else
  #if guess is greater than secret number
    if [[ $NUMBER_GUESS > $SECRET_NUMBER ]]
    then
      echo -e "\nIt's lower than that, guess again:"

    #if guess is less than secret number
    elif [[ $NUMBER_GUESS < $SECRET_NUMBER ]]
    then
      echo -e "\nIt's higher than that, guess again:"

    fi
  fi

  #counter increments at the end of each guess
  NUMBER_OF_GUESSES=$(($NUMBER_OF_GUESSES+1))
done

#display secret number and number of guesses made
echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

#update stats
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players set games_played = games_played+1 WHERE username = '$USERNAME'")
UPDATE_BETST_GAME=$($PSQL "UPDATE players SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME' AND (best_game IS NULL OR best_game > $NUMBER_OF_GUESSES)")
