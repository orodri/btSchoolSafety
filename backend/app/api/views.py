from django.http import HttpResponse
from django.views.decorators.http import require_http_methods
import json
from system.models import System


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
