from django.shortcuts import render, redirect


def index(request):
    response = redirect('/panic/')
    return response
