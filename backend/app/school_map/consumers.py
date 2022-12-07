import json

from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer
from school_map.directory_level_reporting import compute_students_near_rooms
from school_map.models import Beacon, Student

from school_map.validators import validate_nearest_json, validate_precise_location_json, validate_chat_json

from school_map.validators import validate_nearest_json, validate_precise_location_json
from school_map.directory_level_reporting import compute_total_students
from school_map.directory_level_reporting import compute_medical_students
from school_map.directory_level_reporting import compute_safe_students
from school_map.directory_level_reporting import compute_danger_students

from easy_trilateration.model import Circle
from trilateration import trilateration


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
        elif 'chat_content' in received_json:
            self.on_received_chat_update(received_json)

    def on_received_chat_update(self, received_json):
        if not validate_chat_json(received_json):
            return
        chat_content = received_json['chat_content']
        # Send to the first responders' clients
        async_to_sync(self.channel_layer.group_send)(
            'first_responders', {
                'type': 'chat_update',
                'chat_content': chat_content,
            }
        )
        print("chat received by IOS socket")

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
        total_users = compute_total_students()
        med_users = compute_medical_students()
        safe_users = compute_safe_students()
        danger_users = compute_danger_students()

        # Send to the first responders' clients
        async_to_sync(self.channel_layer.group_send)(
            'first_responders', {
                'type': 'directory_level_update',
                'room_counts': room_counts,
                'total_users': total_users,
                'med_users': med_users,
                'safe_users': safe_users,
                'danger_users': danger_users,
            }
        )

    def on_received_precise_location_update(self, received_json):
        if not validate_precise_location_json(received_json):
            return

        seen_beacons = received_json['beacons']
        trilat_inputs = []
        for seen_beacon in seen_beacons:
            db_beacon = Beacon.objects.filter(
                minor=seen_beacon['minor']).first()
            if db_beacon:
                trilat_inputs += [Circle(
                    db_beacon.position_x,
                    db_beacon.position_y,
                    seen_beacon['distance']
                )]
        estimated_position = trilateration(trilat_inputs)

        anon_identifier = received_json['anonIdentifier']
        student, _ = Student.objects.get_or_create(
            anon_identifier=anon_identifier)

        old_pos_x = student.position_x
        old_pos_y = student.position_y
        if old_pos_x and old_pos_y:
            student.position_x = (old_pos_x + estimated_position[0]) * 0.5
            student.position_y = (old_pos_y + estimated_position[1]) * 0.5
        else:
            student.position_x = estimated_position[0]
            student.position_y = estimated_position[1]

        student.save()

        students = Student.objects.all()
        student_positions = {}
        for s in students:
            s_has_position = s.position_x is not None and s.position_y is not None
            student_positions[s.anon_identifier] = {
                'x': s.position_x,
                'y': s.position_y
            } if s_has_position else None

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
        total_users = event['total_users']
        med_users = event['med_users']
        safe_users = event['safe_users']
        danger_users = event['danger_users']

        self.send(text_data=json.dumps({
            'roomCounts': room_counts,
            'totalUsers': total_users,
            'medUsers': med_users,
            'safeUsers': safe_users,
            'dangerUsers': danger_users,
        }))

    def precise_location_update(self, event):
        student_positions = event['student_positions']
        self.send(text_data=json.dumps({
            'studentPositions': student_positions
        }))

    def chat_update(self, event):
        chat_content = event['chat_content']
        self.send(text_data=json.dumps({
            'chat': chat_content
        }))
