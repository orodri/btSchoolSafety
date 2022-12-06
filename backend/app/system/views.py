from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.template import loader
from django.views.decorators.http import require_http_methods
from django.contrib.auth.decorators import login_required
from system.models import System

from django.views.decorators.csrf import csrf_exempt

import asyncio
import websockets


@login_required
def index(request):

    system = System.objects.first()
    if not system:
        system = System()

    if system.is_tracking_students_locations:
        return redirect('/live-map')
    else:
        return redirect('/panic/')


@login_required
@require_http_methods(["GET"])
def select_alert(request):
    template = loader.get_template('system/select_alert.html')

    return HttpResponse(template.render(None, request))


@login_required
@require_http_methods(["GET"])
def send_active_shooting(request):
    template = loader.get_template('system/send_active_shooting.html')

    return HttpResponse(template.render(None, request))


@login_required
@require_http_methods(["GET"])
def deactivate_page(request):
    template = loader.get_template('system/deactivate.html')

    return HttpResponse(template.render(None, request))


@require_http_methods(["GET", "POST"])
@csrf_exempt
def message_test(request):
    template = loader.get_template('system/message.html')
    if request.method == 'POST':
        # create a form instance and populate it with data from the request:
        print('here')

    async def echo(websocket):
        async for message in websocket:
            await websocket.send(message)

    async def main():
        async with websockets.serve(echo, "localhost", 1111):
            await asyncio.Future()
    asyncio.run(main())
    return HttpResponse(template.render(None, request))
