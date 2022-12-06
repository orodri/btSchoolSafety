from django.urls import path

from . import consumers
websocket_urlpatterns = [
    # What first responders' clients connect to
    path('ws/first-responder',
         consumers.FirstResponderConsumer.as_asgi()),
    # What iOS clients connect to
    path('ws/student', consumers.StudentConsumer.as_asgi()),
]
