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
            room_counts[to_room[s.beacon_minor_closest_to]] += 1

    return room_counts
