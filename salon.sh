#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "~~~Welcome to the Salon~~~\n"
AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services")

echo "Here are some services we offer:"
echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME "
done

echo -e "Please enter the 1, 2 or 3 to select the service you would like to make an appointment for: \n"
read SERVICE_ID_SELECTED

if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3] ]]
then
  CONTINUE=true
  while [ $CONTINUE == true ]
  do
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME "
    done
    echo -e "\nPlease enter the 1, 2 or 3 to select the service you would like to make an appointment for: \n"
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[1-3] ]]
    then 
      CONTINUE=true
    else
      CONTINUE=false
    fi
  done
fi

SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

echo -e "Please enter your phone number:\n"
read CUSTOMER_PHONE

CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
echo $CUSTOMER_NAME

if [[ -z $CUSTOMER_NAME ]]
then
  echo -e "\nPlease enter your name:"
  read CUSTOMER_NAME
  INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo -e "\nPlease enter a time you would like to come:"
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, name, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$CUSTOMER_NAME','$SERVICE_TIME')")
  echo "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
else
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo $CUSTOMER_ID
  echo -e "\nPlease enter a time you would like to come:"
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, name, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$CUSTOMER_NAME','$SERVICE_TIME')")
  echo "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME."
fi

