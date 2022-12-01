from django.urls import path

from . import views

urlpatterns = [
    path('select', views.select_alert)
]
