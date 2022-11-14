from django.db import models

# Create your models here.

class Room(models.Model):
    room_name = models.CharField(max_length=200)
    num_students_nearby = models.IntegerField(default=0)
    beacon_minor = models.IntegerField(null=True, default=None)

class Student(models.Model):
    anon_identifier = models.CharField(max_length=200)
    beacon_minor_closest_to = models.IntegerField(null=True, default=None)