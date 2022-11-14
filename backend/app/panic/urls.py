from django.urls import path

from . import views

urlpatterns = [
    path('', views.index, name='index'),
    path('deactivate', views.deactivate_index, name='deactivate_index'),
]
