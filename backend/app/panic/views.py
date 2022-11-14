from django.shortcuts import render
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from panic.models import Panic
from django.utils import timezone
import json

@csrf_exempt
def panic(request):
    if request.method != 'POST':
        return HttpResponse(status=404)

    body = json.loads(request.body)
    
    p = Panic()
    p.date_received = timezone.now()
    p.panic_type = body['type'] if body.get('type') else 'omitted'
    p.save()

    response = HttpResponse()
    response.status_code = 201

    return response

def index(request):
    return HttpResponse("Hello you're panicking")