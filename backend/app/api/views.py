from django.http import HttpResponse
from django.views.decorators.http import require_http_methods
from django.views.decorators.csrf import csrf_exempt
import json
from system.models import System
from school_map.models import Student


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

    # Send apple push notifications

    return HttpResponse(status=200)


@require_http_methods(["POST"])
def deactivate(request):

    system = System.objects.first()
    if not system:
        system = System()

    system.is_tracking_students_locations = False
    system.emergency_type = None
    system.save()

    # send push notification to apple's push notification service

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
