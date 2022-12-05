from django.contrib import admin

from .models import BuildingMap, Room, Beacon, Student

admin.site.register(BuildingMap)
admin.site.register(Room)
admin.site.register(Beacon)
admin.site.register(Student)
