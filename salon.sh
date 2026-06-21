#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "\nHere are the services we offer:\n"
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id" | while IFS="|" read ID NAME; do echo "$ID) $NAME"; done)"

  read -p $'\nPlease enter a service ID: ' SERVICE_ID_SELECTED

  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE ]]
  then
    MAIN_MENU "That service does not exist."
  else
    read -p $'\nWhat is your phone number? ' CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then
      read -p $'\nI don'"'"'t have a record for that phone number, what is your name? ' CUSTOMER_NAME
      $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')"
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    read -p $'\nWhat time would you like your '"$SERVICE"'? ' SERVICE_TIME

    $PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

    echo -e "\nI have put you down for a $SERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU
