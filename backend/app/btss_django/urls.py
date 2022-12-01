"""btss_django URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/4.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import include, path

from panic import views as panic_views
from school_map import views as school_map_views
from system import views as system_views

urlpatterns = [
    path('', system_views.index, name='index'),
    path('accounts/', include('django.contrib.auth.urls')),
    path('register', school_map_views.register),
    path('panic', panic_views.panic),
    path('panic/', include('panic.urls')),
    path('admin/', admin.site.urls),
    path('deactivate', panic_views.deactivate),
    path('nearest', school_map_views.nearest),
]
