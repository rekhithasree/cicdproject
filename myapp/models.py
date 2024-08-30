from django.db import models

class UserInfo(models.Model):
    name = models.CharField(max_length=100)
    number = models.CharField(max_length=15)
    address = models.CharField(max_length=25, null=True, blank=True)

    def __str__(self):
        return self.name
