from django.db import models

class Panic(models.Model):
    date_received = models.DateTimeField()
    processed = models.BooleanField(default=False)
