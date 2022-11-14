from django.shortcuts import render
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
from panic.models import Panic
from django.utils import timezone
import json
from django.template import loader
from django.views.decorators.http import require_http_methods
from system.models import System

@csrf_exempt
@require_http_methods(["POST"])
def panic(request):
    body = json.loads(request.body)
    
    p = Panic()
    p.date_received = timezone.now()
    p.panic_type = body['type'] if body.get('type') else 'omitted'
    p.save()

    response = HttpResponse()
    response.status_code = 201

    return response

@csrf_exempt
def deactivate(request):
    if request.method != 'POST':
        return HttpResponse(status=404)
    # send push notification to apple's push notification service
    body = json.loads(request.body)

   
    #print(getattr(obj, "is_tracking_students_locations"))



    response = HttpResponse()
    response.status_code = 201
    return response
    
@require_http_methods(["GET"])
def index(request):
    template = loader.get_template('panic/index.html')

    def fix_panic(panic: Panic):
        panic.panic_type = panic.panic_type if panic.panic_type else 'invalid'
        return panic
    panic_alerts = list(map(fix_panic, Panic.objects.all()))

    context = {
        'panic_alerts': panic_alerts
    }
    return HttpResponse(template.render(context, request))

@require_http_methods(["GET"])
def deactivate_index(request):
    template = loader.get_template('panic/deactivate.html')

    def fix_panic(panic: Panic):
        panic.panic_type = panic.panic_type if panic.panic_type else 'invalid'
        return panic
    panic_alerts = list(map(fix_panic, Panic.objects.all()))

    context = {
        'panic_alerts': panic_alerts
    }
    return HttpResponse(template.render(context, request))
