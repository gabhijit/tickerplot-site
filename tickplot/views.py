# Create your views here.
from tickplot.models import Scrips , Nsehistdata
from django.http import HttpResponse, HttpResponseRedirect

#templates stuff
from django.template.loader import get_template
from django.template import Context

## some utils
import json
import re
import urllib2

_email_restr = r"(^[a-zA-Z0-9][a-zA-Z0-9+-_]*@[a-zA-Z0-9-]+\.[a-zA-Z]+$)"
_email_re = re.compile(_email_restr)

def index_placeholder(request):

    if request.method == 'GET':
        t = get_template('index_placeholder.html')
        html = t.render(Context({}))
        return HttpResponse(html)


def interest(request):

    global _email_re

    if request.method == 'POST':
        email = request.POST.get('email')
        if len(email) < 60:
            if not _email_re.match(email):
                return HttpResponse("Sorry Don't recognize that email.")

            with open('interests.txt', 'a+') as f:
                f.write(email)
                f.write("\n")
            return HttpResponse("Success")
        else:
            return HttpResponse("Sorry Email Address too long! Try a smaller one.")

    return HttpResponseRedirect("/")

def scriplist(request):
    s = Scrips.objects.all()
    str = []
    for i in s:
        str.append({'symbol':i.symbol, 'name':i.name})

    jsonstr = json.dumps(str)
    return HttpResponse(jsonstr, content_type='application/json')

def scripdata(request):
    g = request.GET or request.POST

    ### sanitize g['symbol'] and return data for that symbol
    kiddies = re.findall(r'[^0-9a-zA-Z&]+', urllib2.unquote(g['symbol']))
    if kiddies :
        return HttpResponse(403) ## FIXME : Take a closer look

    symbol = g['symbol'].upper()

    data = Nsehistdata.objects.filter(scrip = symbol)
    rows = []
    for d in data:
        rows.append([d.date*1000, d.open, d.high, d.low, d.close, d.volume])
    sdata = { 'label' : symbol, 'data': rows}
    datastr = json.dumps(sdata)
    return HttpResponse(datastr,  content_type="application/json")

def index(request):
    t = get_template('index.html')
    html = t.render(Context({}))
    return HttpResponse(html)
