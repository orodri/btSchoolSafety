from django.urls import path

from . import consumers
websocket_urlpatterns = [
    # What first responders' clients connect to
    path('ws/nearest/first-responder/',
         consumers.DirectoryLevelReportingConsumer.as_asgi()),
    # What iOS clients connect to
    path('ws/nearest/', consumers.LocationTrackingConsumer.as_asgi()),
]
