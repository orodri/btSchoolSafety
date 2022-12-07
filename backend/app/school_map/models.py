from django.db import models

# Create your models here.


class BuildingMap(models.Model):
    upload = models.FileField(upload_to='uploads/')
    default_camera_height = models.FloatField()
    max_camera_height = models.FloatField()
    display_name = models.CharField(max_length=200)


class Room(models.Model):
    room_name = models.CharField(max_length=200)
    num_students_nearby = models.IntegerField(default=0)


class Beacon(models.Model):
    minor = models.IntegerField()
    room_name = models.CharField(max_length=200)
    position_x = models.FloatField(null=True, default=None)
    position_y = models.FloatField(null=True, default=None)


class Student(models.Model):
    anon_identifier = models.CharField(max_length=200)
    beacon_minor_closest_to = models.IntegerField(null=True, default=None)
    position_x = models.FloatField(null=True, default=None)
    position_y = models.FloatField(null=True, default=None)
    user_reported_status = models.CharField(
        max_length=200, default=None, null=True)
