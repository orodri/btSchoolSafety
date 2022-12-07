import json

from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer
from school_map.directory_level_reporting import compute_students_near_rooms
from school_map.models import Student
from school_map.validators import validate_nearest_json, validate_precise_location_json, validate_chat_json


# What the iOS clients are connecting to
class StudentConsumer(WebsocketConsumer):
    def connect(self):
        # Accept the connection
        self.accept()

    def disconnect(self, close_code):
        pass

    # Receive a message from iOS client
    def receive(self, text_data=None, bytes_data=None):
        received_json = None
        if text_data:
            received_json = json.loads(text_data)
        elif bytes_data:
            received_json = json.loads(bytes_data.decode())

        # Handle different types of messages
        if 'nearest' in received_json:
            self.on_received_directory_level_update(received_json)
        elif 'beacons' in received_json:
            self.on_received_precise_location_update(received_json)
        elif 'chat' in received_json:
            self.on_received_chat_update(received_json)

    def on_received_chat_update(self, received_json):
        if not validate_chat_json(received_json):
            return
        chat_content = received_json['chat']
        anon_identifier = received_json['anonIdentifier']
        # Send to the first responders' clients
        async_to_sync(self.channel_layer.group_send)(
            'first_responders', {
                'type': 'student_chat_update',
                'anonIdentifier': anon_identifier,
                'chat_content': chat_content,
            }
        )

    def on_received_directory_level_update(self, received_json):
        if not validate_nearest_json(received_json):
            return

        # Retrieve and update student from database
        anon_identifier = received_json['anonIdentifier']
        nearest_beacon_minor = received_json['nearest']

        student, _ = Student.objects.get_or_create(
            anon_identifier=anon_identifier)
        student.beacon_minor_closest_to = nearest_beacon_minor
        student.save()

        room_counts = compute_students_near_rooms()

        # Send to the first responders' clients
        async_to_sync(self.channel_layer.group_send)(
            'first_responders', {
                'type': 'directory_level_update',
                'room_counts': room_counts,
            }
        )

    def on_received_precise_location_update(self, received_json):
        if not validate_precise_location_json(received_json):
            return

        # TODO: trilaterate
        student_positions = {
            received_json['anonIdentifier']: {
                'x': 1.9,
                'y': 3.8
            }
        }
        async_to_sync(self.channel_layer.group_send)(
            'first_responders', {
                'type': 'precise_location_update',
                'student_positions': student_positions
            }
        )


# What the first responders clients are connecting to
class FirstResponderConsumer(WebsocketConsumer):
    def connect(self):
        async_to_sync(self.channel_layer.group_add)(
            'first_responders', self.channel_name
        )
        self.accept()

    def disconnect(self, close_code):
        async_to_sync(self.channel_layer.group_discard)(
            'first_responders', self.channel_name
        )

    def receive(self, text_data=None, bytes_data=None):
        pass

    # Send to the first responders' clients
    def directory_level_update(self, event):
        room_counts = event['room_counts']
        self.send(text_data=json.dumps({
            'roomCounts': room_counts
        }))

    def precise_location_update(self, event):
        student_positions = event['student_positions']
        self.send(text_data=json.dumps({
            'studentPositions': student_positions
        }))
