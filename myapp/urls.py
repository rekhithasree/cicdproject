from django.urls import path
from .views import user_info_view, success_view

urlpatterns = [
    path('', user_info_view, name='user_info'),
    path('success/', success_view, name='success'),
]
    