# Generated by Django 4.1.3 on 2022-11-13 23:48

from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
    ]

    operations = [
        migrations.CreateModel(
            name='Panic',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('date_received', models.DateTimeField()),
                ('processed', models.BooleanField(default=False)),
            ],
        ),
    ]