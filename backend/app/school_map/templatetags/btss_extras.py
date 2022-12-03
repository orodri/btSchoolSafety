from django import template
from django.utils.safestring import mark_safe

register = template.Library()


@register.filter
def quote(value):
    return mark_safe(f'"{value}"' if value else 'null')


@register.filter
def to_color(value):
    match value:
        case 'active-shooting':
            return 'red'
        case 'fire':
            return 'orange'
        case 'other':
            return 'yellow'
        case _:
            return 'black'


@register.filter
def to_label(value):
    match value:
        case 'active-shooting':
            return 'Active shooting'
        case 'fire':
            return 'Fire'
        case 'other':
            return 'Other'
        case _:
            return value
