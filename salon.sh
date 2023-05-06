#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  
  # show available services
  SERVICES=$($PSQL "select service_id, name from services order by service_id")
  
  # if there is no service available
  if [[ -z $SERVICES ]]
  then
    echo "Sorry, we don't have any service available right now"
  
  # if id available show them formatted 
  else
    echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
    do
      echo "$SERVICE_ID) $NAME"
    done
  
  # get customer choice
  read SERVICE_ID_SELECTED
    
    # if the choice is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
      MAIN_MENU "Sorry, that is not a valid number! Please, choose again."
    else
      VALID_SERVICE=$($PSQL "select service_id from services where service_id = $SERVICE_ID_SELECTED")
      
      # if service id is not in the table
      if [[ -z $VALID_SERVICE ]]
      then

        # send to main menu
        MAIN_MENU "I could not find that service. Please select the available service"
      else
        echo -e "\nEnter your phone number"
        read CUSTOMER_PHONE

        # check if is a new customer or not
        CUSTOMER_NAME=$($PSQL "Select name from customers where phone = '$CUSTOMER_PHONE'")

        # if is customer not in the record
        if [[ -z $CUSTOMER_NAME ]]
        then
          echo -e "\nLooks like you are a new customer, what is your name?"
          read CUSTOMER_NAME
          ADD_CUSTOMER_INFO=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
          SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

          # get the time the customer wants to appoint
          echo "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'),$(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
          read SERVICE_TIME

          # update the appointment table
          CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
          APPOINTMENT_BOOKING=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
          echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."

          # case is an old customer
          else
            # get the service name and ask for the time the customer wants to appoint
            SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
            echo "What time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
            read SERVICE_TIME
            # update the appointment table  
            CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
            APPOINTMENT_BOOKING=$($PSQL "insert into appointments(customer_id, service_id, time) values($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
            echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
        fi
      fi
    fi
  fi  
}

MAIN_MENU