from django.db import models


class System(models.Model):
    is_tracking_students_locations = models.BooleanField(default=False)
    emergency_type = models.CharField(max_length=200, default=None, null=True)
