from django.urls import path

from . import views

urlpatterns = [
    path('activate', views.activate),
    path('deactivate', views.deactivate),
]