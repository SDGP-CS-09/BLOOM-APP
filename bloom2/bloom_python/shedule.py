import firebase_admin
from firebase_admin import credentials, db
import serial
import time
from datetime import datetime
from pprint import pprint

# ----------------------
# Configuration
# ----------------------
FIREBASE_CREDENTIALS = "bloomapp-f4a5b-firebase-adminsdk-fbsvc-f3a7dad8b6.json"
SERIAL_PORT = 'COM4'  # Replace with your port
BAUD_RATE = 9600

# ----------------------
# Error Handling
# ----------------------
def handle_error(error_type, message):
    print(f"\n[ERROR] {error_type}: {message}")

# ----------------------
# Initialize Firebase
# ----------------------
try:
    cred = credentials.Certificate(FIREBASE_CREDENTIALS)
    firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://bloomapp-f4a5b-default-rtdb.asia-southeast1.firebasedatabase.app/'
    })
    print("Firebase initialized successfully.")
except Exception as e:
    handle_error("Firebase Initialization", f"Failed to initialize: {str(e)}")
    exit(1)

# ----------------------
# Serial Communication Setup
# ----------------------
# try:
#     ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1)
#     time.sleep(2)
#     print(f"Connected to Arduino/ESP8266 at {SERIAL_PORT}")
# except Exception as e:
#     handle_error("Serial Connection", f"Failed to connect: {str(e)}")
#     exit(1)

# ----------------------
# Time Handling
# ----------------------
def normalize_time(time_str):
    """Normalize time string to HH:MM format"""
    if time_str == "N/A":
        return time_str
    
    try:
        # Handle ISO format timestamps
        if 'T' in time_str:
            dt = datetime.fromisoformat(time_str.replace('Z', '+00:00'))
            return dt.strftime("%H:%M")
        
        # Handle normal time strings
        if ':' in time_str:
            return ":".join(time_str.split(":")[:2])
        
        return time_str
    except Exception as e:
        handle_error("Time Normalization", f"Failed to normalize time {time_str}: {str(e)}")
        return "N/A"

# ----------------------
# Fetch & Organize Schedules
# ----------------------
def fetch_schedules():
    plant_schedules = {
        "potato": [],
        "bellpepper": [],
        "chilli": [],
        "egg-plant": [],
        "tomato": []
    }

    try:
        ref = db.reference('plants')
        plants = ref.get()

        for plant_id, plant_data in plants.items():
            if plant_id not in plant_schedules:
                print(f"[WARNING] Skipping unknown plant: {plant_id}")
                continue

            schedules = plant_data.get("schedules", {})
            for schedule_id, schedule in schedules.items():
                try:
                    normalized_time = normalize_time(schedule.get("time", "N/A"))
                    
                    plant_schedules[plant_id].append({
                        "date": schedule.get("date", "N/A"),
                        "time": normalized_time,
                        "duration": int(schedule.get("duration_seconds", 0))
                    })
                except Exception as e:
                    handle_error("Data Parsing", f"Invalid schedule {schedule_id}: {str(e)}")

        # Print all schedules
        print("\nCurrent Plant Schedules:")
        for plant, schedules in plant_schedules.items():
            print(f"{plant.upper()} ({len(schedules)} schedules):")
            pprint(schedules, indent=2)
            print("-" * 40)

        return plant_schedules

    except Exception as e:
        handle_error("Database Fetch", f"Failed to fetch data: {str(e)}")
        return plant_schedules

# ----------------------
# Watering Control Logic
# ----------------------
def control_pump(plant_id, schedule):
    try:
        # Send ON command
        ser.write(b"ON\n")
        start_msg = (
            f"\n[START] Watering {plant_id} | "
            f"Date: {schedule['date']} | "
            f"Time: {schedule['time']} | "
            f"Duration: {schedule['duration']}s"
        )
        print(start_msg)

        # Wait for duration
        time.sleep(schedule['duration'])

        # Send OFF command
        ser.write(b"OFF\n")
        completion_msg = f"""
        ======================================
        [COMPLETE] Watering Done!
        Plant: {plant_id}
        Date: {schedule['date']}
        Start Time: {schedule['time']}
        Duration: {schedule['duration']} seconds
        ======================================
        """
        print(completion_msg)

    except Exception as e:
        handle_error("Pump Control", f"Failed to water {plant_id}: {str(e)}")

# ----------------------
# Main Loop
# ----------------------
try:
    while True:
        current_date = datetime.now().strftime("%Y-%m-%d")
        current_time = datetime.now().strftime("%H:%M")  # HH:MM

        schedules = fetch_schedules()
        for plant_id, plant_schedules in schedules.items():
            for schedule in plant_schedules:
                try:
                    if (
                        schedule['date'] == current_date and
                        schedule['time'] != "N/A" and
                        schedule['time'] == current_time and
                        schedule['duration'] > 0
                    ):
                        control_pump(plant_id, schedule)
                except KeyError as e:
                    handle_error("Schedule Check", f"Missing key {str(e)}")

        time.sleep(30)  # Check every 30 seconds

except KeyboardInterrupt:
    print("\nExiting program...")
    ser.close()
except Exception as e:
    handle_error("Critical Failure", f"Main loop crashed: {str(e)}")
    ser.close()