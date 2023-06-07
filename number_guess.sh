#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only -c"


# Generate a random secret number between 1 and 1000
secret_number=$((RANDOM % 1000 + 1))

# Initialize the number of guesses to 0
num_guesses=0

# Function to check if input is an integer
function is_integer() {
  [[ $1 =~ ^[0-9]+$ ]]
}

echo "Enter your username:"
read ENTERED_USERNAME

USERNAME=$($PSQL "SELECT * FROM users WHERE username = '$ENTERED_USERNAME'")

if [[ $USERNAME ]]
then
 echo "$USERNAME" | while read NAME BAR GAMES_PLAYED BAR BEST_GAME
      do
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
      done
fi

if [[ -z $USERNAME ]]
then
INSERTED_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$ENTERED_USERNAME')")
USERNAME=$($PSQL "SELECT * FROM users WHERE username = '$ENTERED_USERNAME'")
echo "Welcome, $ENTERED_USERNAME! It looks like this is your first time here."
fi


USERS_TOTAL_GAMES=$($PSQL "SELECT games_played FROM users WHERE username = '$ENTERED_USERNAME'")
USERS_BEST_GUESS=$($PSQL "SELECT best_game FROM users WHERE username = '$ENTERED_USERNAME'")
echo "Guess the secret number between 1 and 1000:"
# Main game loop
while true; do

  read guess

  # Check if the input is an integer
  if ! is_integer "$guess"; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Increment the number of guesses
  ((num_guesses++))

  # Compare the guess with the secret number
  if ((guess < secret_number)); then
    echo "It's higher than that, guess again:"
  elif ((guess > secret_number)); then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $num_guesses tries. The secret number was $secret_number. Nice job!"

if [[ $USERS_TOTAL_GAMES < 1  || $num_guesses < $USERS_BEST_GUESS ]]
then
    INSERTED_WINNER=$($PSQL "UPDATE users SET best_game = $num_guesses WHERE username = '$ENTERED_USERNAME'")
fi
   
((USERS_TOTAL_GAMES++))
INSERTED_ADD_GAMES=$($PSQL "UPDATE users SET games_played = $USERS_TOTAL_GAMES WHERE username = '$ENTERED_USERNAME'")

    break
  fi
done