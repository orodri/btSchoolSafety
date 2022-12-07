from django.http import HttpResponse
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
import json
from system.models import System
from school_map.models import Student
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync


@require_http_methods(["POST"])
def activate(request):

    if not request.user.is_authenticated:
        return HttpResponse(status=401)

    body = json.loads(request.body)

    system = System.objects.first()
    if not system:
        system = System()

    system.is_tracking_students_locations = True

    match body['emergencyType']:
        case 'active-shooting' | 'fire' | 'other':
            system.emergency_type = body['emergencyType']
        case _:
            return HttpResponse(status=400)

    system.save()

    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        'students', {
            'type': 'system_status_broadcast',
            'systemStatus': {
                'isActive': system.is_tracking_students_locations,
                'emergencyType': system.emergency_type,
            }
        }
    )

    return HttpResponse(status=200)


@require_http_methods(["POST"])
def deactivate(request):

    system = System.objects.first()
    if not system:
        system = System()

    system.is_tracking_students_locations = False
    system.emergency_type = None
    system.save()

    channel_layer = get_channel_layer()
    async_to_sync(channel_layer.group_send)(
        'students', {
            'type': 'system_status_broadcast',
            'systemStatus': {
                'isActive': system.is_tracking_students_locations,
                'emergencyType': system.emergency_type,
            }
        }
    )

    return HttpResponse(status=200)


@csrf_exempt
@require_http_methods(["POST"])
def status(request):

    body = json.loads(request.body)

    s, _ = Student.objects.get_or_create(
        anon_identifier=body['anonIdentifier'])

    s.user_reported_status = body['type']
    s.save()

    response = HttpResponse()
    response.status_code = 201

    return response
