from django.urls import path

from . import views

urlpatterns = [
    path('select', views.select_alert),
    path('send-active-shooting', views.send_active_shooting),
    path('deactivate', views.deactivate_page),
]
