import csv
import os
from datetime import datetime

filename = 'Testing.csv'
current_year = datetime.now().year

# Check if file exists once at the start
file_exists = os.path.isfile(filename)

print("--- Data Entry System ---")

while True:
    # --- 1. Name Validation ---
    while True:
        name = input("Enter Name: ").strip()
        if name.replace(" ", "").isalpha() and len(name) > 0:
            break
        else:
            print("Please enter a valid Name ")

    # --- 2. IC Validation ---
    while True:
        identification_card = input("Enter IC no. (12 digits): ").strip()
        if identification_card.isdigit() and len(identification_card) == 12:
            break
        else:
            print("Please enter a valid 12-digit IC number.")

    # --- 3. Date of Birth Validation ---
    while True:
        print("\n--- Date of Birth ---")
        day_input = input("Enter day (DD): ").strip()
        month_input = input("Enter month (MM): ").strip()
        year_input = input("Enter year (YYYY): ").strip()

        if not (day_input.isdigit() and month_input.isdigit() and year_input.isdigit()):
            print("Date values must be numeric.")
            continue

        if len(year_input) != 4:
            print("Please enter 4 digits for the year.")
            continue

        day = int(day_input)
        month = int(month_input)
        year = int(year_input)

        if not (1800 <= year <= current_year):
            print(f"Year must be between 1800 and {current_year}.")
            continue

        try:
            birthday_dt = datetime(year, month, day)
            birthday = birthday_dt.strftime("%Y-%m-%d")
            break
        except ValueError:
            print("Invalid date. Please try again.")

    # --- 4. Other Inputs ---
    contact_number = input("Contact No.: ").strip()
    email = input("Email: ").strip()
    address = input("Enter Address: ").strip()

    # --- NEW: Generate Timestamp ---
    # Captures the exact moment of registration
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # --- 5. Save to CSV ---
    try:
        with open(filename, 'a', newline='') as file:
            writer = csv.writer(file)
            
            # Update Header: Added "registration_timestamp" at the end
            if not file_exists:
                writer.writerow(["name", "identification_card", "birthday", "address", "contact_number", "email", "registration_timestamp"])
                file_exists = True 
            
            # Update Row: Added variable 'timestamp' at the end
            writer.writerow([name, identification_card, birthday, address, contact_number, email, timestamp])
            
            print(f"\n>> Data for {name} saved at {timestamp}!")
            
    except PermissionError:
        print(f"Error: Could not save to {filename}")
        break
