# Generated by Django 4.1.3 on 2022-12-05 21:38

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('school_map', '0002_beacon_remove_room_beacon_minor'),
    ]

    operations = [
        migrations.CreateModel(
            name='BuildingMap',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('upload', models.FileField(upload_to='uploads/')),
                ('default_camera_height', models.FloatField()),
                ('max_camera_height', models.FloatField()),
                ('display_name', models.CharField(max_length=200)),
            ],
        ),
    ]
