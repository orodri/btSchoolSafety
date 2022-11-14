from django.shortcuts import render
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt

from django.utils import timezone
import json
from django.template import loader
from django.views.decorators.http import require_http_methods
import uuid

from school_map.models import Student

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
def deactivate(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    # send push notification to apple's push notification service
    body = json.loads(request.body)
    

    response = HttpResponse()
    response.status_code = 201
    return response