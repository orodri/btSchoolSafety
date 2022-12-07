from school_map.models import Room, Beacon, Student


def compute_students_near_rooms():
    # First get all rooms
    rooms = Room.objects.all()
    room_counts = {}
    for room in rooms:
        room_counts[room.room_name] = 0

    # Create Beacon -> Room map
    beacons = Beacon.objects.all()
    to_room = {}
    for beacon in beacons:
        to_room[beacon.minor] = beacon.room_name

    # Map Student -> Beacon -> Room and then tally
    students = Student.objects.all()
    for s in students:
        if s.beacon_minor_closest_to:
            if s.beacon_minor_closest_to in to_room:
                room_counts[to_room[s.beacon_minor_closest_to]] += 1

    return room_counts


def compute_total_students():

    num_Of_Students = 0
    students = Student.objects.all()
    for s in students:
        num_Of_Students += 1

    return num_Of_Students


def compute_medical_students():

    num_med = 0
    students = Student.objects.all()
    for s in students:
        if s.user_reported_status == "requesting-medical":
            num_med += 1

    return num_med


def compute_safe_students():

    num_safe = 0
    students = Student.objects.all()
    for s in students:
        if s.user_reported_status == "is-safe":
            num_safe += 1

    return num_safe


def compute_danger_students():

    num_danger = 0
    students = Student.objects.all()
    for s in students:
        if s.user_reported_status == "sees-shooter":
            num_danger += 1

    return num_danger
