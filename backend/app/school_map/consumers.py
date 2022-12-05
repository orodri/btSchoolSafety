import json

from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer
from school_map.models import Room, Beacon, Student


def _validate_nearest_json(received_json):
    if 'anonIdentifier' not in received_json:
        return False
    if 'nearest' not in received_json:
        return False
    if type(received_json['anonIdentifier']) is not str:
        return False
    if type(received_json['nearest']) is not int and received_json['nearest'] is not None:
        return False

    return True


def _compute_students_near_rooms():
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


# What the iOS clients are connecting to
class LocationTrackingConsumer(WebsocketConsumer):
    def connect(self):
        # Accept the connection
        self.accept()

    def disconnect(self, close_code):
        pass

    def receive(self, text_data=None, bytes_data=None):
        # Received a nearest beacon update from an iOS client
        received_json = None
        if text_data:
            received_json = json.loads(text_data)
        elif bytes_data:
            received_json = json.loads(bytes_data.decode())

        if not _validate_nearest_json(received_json):
            return

        # Retrieve and update student from database
        anon_identifier = received_json['anonIdentifier']
        nearest_beacon_minor = received_json['nearest']

        student, _ = Student.objects.get_or_create(
            anon_identifier=anon_identifier)
        student.beacon_minor_closest_to = nearest_beacon_minor
        student.save()

        room_counts = _compute_students_near_rooms()

        # Send to the first responders' clients
        async_to_sync(self.channel_layer.group_send)(
            'first_responder_directory_level_updates', {
                'type': 'directory_level_update',
                'room_counts': room_counts
            }
        )


# What the first responders clients are connecting to
class DirectoryLevelReportingConsumer(WebsocketConsumer):
    def connect(self):
        async_to_sync(self.channel_layer.group_add)(
            'first_responder_directory_level_updates', self.channel_name
        )
        self.accept()

    def disconnect(self, close_code):
        async_to_sync(self.channel_layer.group_discard)(
            'first_responder_directory_level_updates', self.channel_name
        )

    def receive(self, text_data=None, bytes_data=None):
        pass

    # Send to the first responders' clients
    def directory_level_update(self, event):
        room_counts = event['room_counts']
        self.send(text_data=json.dumps({
            'roomCounts': room_counts
        }))
