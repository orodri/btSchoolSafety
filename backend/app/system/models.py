from django.db import models

class System(models.Model):
    is_tracking_students_locations = models.BooleanField(default=False) # false when deactivated
