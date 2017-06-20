from django.conf.urls import url

from . import views

urlpatterns = [
            url(r'^$', views.index, name="index"),
            url(r'^scrips$', views.scriplist, name="scriplist"),
            url(r'^sd$', views.scripdata, name="scripdata"),
        ]

