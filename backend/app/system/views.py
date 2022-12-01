from django.shortcuts import render, redirect
from django.http import HttpResponse
from django.template import loader
from django.views.decorators.http import require_http_methods
from django.contrib.auth.decorators import login_required


def index(request):
    response = redirect('/panic/')
    return response


@login_required
@require_http_methods(["GET"])
def select_alert(request):
    template = loader.get_template('system/select_alert.html')

    return HttpResponse(template.render(None, request))
