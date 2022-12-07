from django.shortcuts import render
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt

from django.utils import timezone
import json
from django.template import loader
from django.views.decorators.http import require_http_methods
from django.contrib.auth.decorators import login_required
import uuid

from school_map.models import BuildingMap, Student
from system.models import System
from school_map.directory_level_reporting import compute_students_near_rooms
from school_map.directory_level_reporting import compute_total_students
from school_map.directory_level_reporting import compute_medical_students
from school_map.directory_level_reporting import compute_safe_students
from school_map.directory_level_reporting import compute_danger_students


@csrf_exempt
@require_http_methods(["POST"])
def register(request):

    s = Student()
    s.anon_identifier = f'{uuid.uuid4()}'
    s.save()

    response = HttpResponse()
    response.status_code = 201
    body_as_str = json.dumps({
        'anon_identifier': s.anon_identifier
    })
    response.write(body_as_str)
    print(response)

    return response


@csrf_exempt
@require_http_methods(["POST"])
def nearest(request):

    body = json.loads(request.body)

    anon_identifier = body['anonIdentifier']
    beacon_minor_closest_to = body['nearest']
    s = Student.objects.filter(anon_identifier=anon_identifier).all()
    if len(s) == 0:
        s = Student()
        s.anon_identifier = anon_identifier
    else:
        s = s[0]
    s.beacon_minor_closest_to = beacon_minor_closest_to
    s.save()

    response = HttpResponse()
    response.status_code = 200
    return response


@login_required
@require_http_methods(["GET"])
def map_page(request):

    system = System.objects.first()
    if not system:
        system = System()
        system.save()

    building_map = BuildingMap.objects.first()
    room_counts = compute_students_near_rooms()
    total_users = compute_total_students()
    med_users = compute_medical_students()
    safe_users = compute_safe_students()
    danger_users = compute_danger_students()

    context = {
        'emergency_type': system.emergency_type,
        'building_name': building_map.display_name if building_map else None,
        'map_file_path': "media/" + building_map.upload.name if building_map else None,
        'default_camera_height': building_map.default_camera_height if building_map else 0,
        'max_camera_height': building_map.max_camera_height if building_map else 0,
        'room_counts': room_counts,
        'total_users': total_users,
        'med_users': med_users,
        'safe_users': safe_users,
        'danger_users': danger_users,
    }

    template = loader.get_template('school_map/live_map_base.html')

    return HttpResponse(template.render(context, request))
