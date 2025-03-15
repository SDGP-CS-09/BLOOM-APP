import firebase_admin
from firebase_admin import credentials, db
from datetime import datetime, timedelta
import time
import json

def initialize_firebase():
    """Initialize Firebase with error handling."""
    try:
        cred = credentials.Certificate("bloomapp-f4a5b-firebase-adminsdk-fbsvc-f3a7dad8b6.json")
        firebase_admin.initialize_app(cred, {
            "databaseURL": "https://bloomapp-f4a5b-default-rtdb.asia-southeast1.firebasedatabase.app/"
        })
        print("✅ Firebase initialization successful")
    except FileNotFoundError:
        print("❌ Error: Firebase credentials file not found")
        raise
    except Exception as e:
        print(f"❌ Error initializing Firebase: {str(e)}")
        raise

def parse_duration(duration_str):
    """Parse duration string to extract the numeric value."""
    try:
        # Remove 'seconds' and any whitespace, then convert to integer
        duration = str(duration_str).replace('seconds', '').strip()
        return int(duration)
    except (ValueError, TypeError) as e:
        print(f"❌ Error parsing duration value: {str(e)}")
        return 0

def update_pump_state(state, plant_id, duration=0):
    """Update pump state in Firebase."""
    try:
        pump_ref = db.reference("pump_control")
        pump_ref.set({
            "state": state,
        })
        print(f"🚰 Pump {'ON' if state else 'OFF'} for plant {plant_id}")
    except Exception as e:
        print(f"❌ Error updating pump state: {str(e)}")

def parse_datetime(datetime_str):
    """Parse datetime string into separate date and time."""
    try:
        dt = datetime.strptime(datetime_str, "%Y-%m-%dT%H:%M:%S.%f")
        return {
            'date': dt.strftime("%Y-%m-%d"),
            'time': dt.strftime("%H:%M"),
            'datetime_obj': dt
        }
    except ValueError as e:
        print(f"❌ Error parsing datetime: {str(e)}")
        return None

def get_plant_schedules():
    """Fetch and organize plant schedules from Firebase."""
    plant_schedules = {}
    try:
        ref = db.reference("plants")
        data = ref.get()
        
        if data:
            for plant, details in data.items():
                if "schedules" in details:
                    plant_schedules[plant] = {}
                    for schedule_id, schedule in details["schedules"].items():
                        datetime_info = parse_datetime(schedule["date"])
                        if datetime_info:
                            plant_schedules[plant][schedule_id] = {
                                'date': datetime_info['date'],
                                'time': datetime_info['time'],
                                'duration': parse_duration(schedule['duration']),  # Parse duration here
                                'datetime_obj': datetime_info['datetime_obj']
                            }
        
        return plant_schedules
    except Exception as e:
        print(f"❌ Error fetching plant schedules: {str(e)}")
        return {}

def check_time_match(schedule_datetime, current_time):
    """Check if current_time is within ±5 minutes of schedule_time."""
    time_before = schedule_datetime - timedelta(minutes=5)
    time_after = schedule_datetime + timedelta(minutes=5)
    return time_before <= current_time <= time_after

def process_schedules():
    """Process all plant schedules and check for time matches."""
    try:
        current_time = datetime.now()
        print("\n🕒 Current Time:", current_time.strftime("%d-%m-%Y %H:%M:%S"))

        plant_schedules = get_plant_schedules()
        
        print("\n📊 Plant Schedules:")
        for plant, schedules in plant_schedules.items():
            print(f"\n{plant.capitalize()}:")
            for schedule_id, schedule in schedules.items():
                print(f"  - Schedule {schedule_id}:")
                print(f"    Date: {schedule['date']}")
                print(f"    Time: {schedule['time']}")
                print(f"    Duration: {schedule['duration']} seconds")

        print("\n⏰ Checking Time Matches...")
        for plant, schedules in plant_schedules.items():
            for schedule_id, schedule in schedules.items():
                try:
                    if check_time_match(schedule['datetime_obj'], current_time):
                        time_diff = (current_time - schedule['datetime_obj']).total_seconds() / 60
                        
                        print("\n✅ Time Match Found!")
                        print(f"  Plant     : {plant.capitalize()}")
                        print(f"  Schedule  : {schedule_id}")
                        print(f"  Date      : {schedule['date']}")
                        print(f"  Time      : {schedule['time']}")
                        print(f"  Duration  : {schedule['duration']} seconds")
                        print(f"  Time Diff : {time_diff:.1f} minutes")
                        print("-" * 30)

                        # Turn pump ON
                        update_pump_state(True, plant, schedule['duration'])
                        
                        # Wait for the duration - duration is already an integer now
                        print(f"⏳ Watering for {schedule['duration']} seconds...")
                        time.sleep(schedule['duration'])
                        
                        # Turn pump OFF
                        update_pump_state(False, plant)
                
                except (ValueError, KeyError) as e:
                    print(f"❌ Error processing schedule {schedule_id} for {plant}: {str(e)}")

    except Exception as e:
        print(f"❌ Error in process_schedules: {str(e)}")

def main():
    """Main execution loop."""
    try:
        initialize_firebase()
        
        while True:
            process_schedules()
            print("\n⏳ Waiting for next check (3 minutes)...")
            time.sleep(180)  # 3 minutes
    
    except KeyboardInterrupt:
        print("\n👋 Program terminated by user")
    except Exception as e:
        print(f"❌ Fatal error: {str(e)}")

if __name__ == "__main__":
    main()