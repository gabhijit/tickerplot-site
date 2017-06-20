# Create your views here.
from tickp.models import Scrips , Nsehistdata
from django.http import HttpResponse

#templates stuff
from django.template.loader import get_template
from django.template import Context

## some utils
import json
import re
import urllib2

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
