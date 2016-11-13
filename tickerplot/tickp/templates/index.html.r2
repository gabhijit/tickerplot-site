<html>
<head>
    <!-- Adds support for the Chrome Frame IE plugin -->
    <meta http-equiv="X-UA-Compatible" content="chrome=1">
                
    <script type="text/javascript" src="/media/jquery.js"></script>
    <script type="text/javascript" src="/media/jquery.autocomplete.js"></script>
    <script type="text/javascript" src="/media/stats.js"></script>
    <script type="text/javascript" src="/media/jsta.js"></script>
    <link rel="stylesheet" type="text/css" href="/media/jquery.autocomplete.css" />
    <link rel="shortcut icon" type="image/png" href="/media/tickerplot.ico">
    <script>
    function defParams() { 
        var i = $("#selectindicator").val();
        var val; 
        switch(i) { 
        case 'ema':
        case 'sma': 
            val = 'close,20';
            break;
        case 'psar': 
            val = '0.02, 0.2';
            break;
        case 'bbands': 
            val = '20,2.0';
            break;
        case 'stoch':
            val = '15,5,5';
            break;
        case 'rsi':
            val = '14';
            break;
        case 'macd':
            val = '12,26,9';
            break;
        default:
            break;
        } 
        $("#paramtxt").val(val);
        return true;
    } 
        

    vmsg = '';
    function validParams(type, params) {
        var notalpha = /[^a-z]+/g
        var notnumeric = /[^0-9]+/g
        var isfloat = /(^\.|[0-9]+\.)[0-9]+$/g
        switch(type) {

        case 'ema':
        case 'sma':
            if (params.length != 2) {
                vmsg = 'invalid length of params : expected 2, received ' + params.length;
                return false;
            } 
            if (params[0].match(notalpha)) { 
                vmsg = 'first parameter ' + params[0]+ 'is in incorrect format.';
                return false;
            } 
            if (params[1].match(notnumeric)) { 
                vmsg = 'second parameter '+ params[1]+ 'is in incorrect format.';
                return false;
            }   
            var validmas = ['open', 'high', 'low', 'close']
            var matched = false;
            for (i in validmas) { 
                if (validmas[i] === params[0]) {
                    matched = true;
                } 
            }
            if(!matched) vmsg = 'first parameter is not one of open,high,low,close';
            return matched;
        case 'bbands':
        case 'psar':
            if(params.length != 2) { 
                vmsg = 'Invalid length of params: expected 2, received ' + params.length;
                return false;
            } 
            for (var i in params) { 
                if (params[i].match(notnumeric) && !params[i].match(isfloat)) {
                    vmsg = 'parameter ' + params[i]+ ' is not in correct format';
                    return false; 
                }
            }
            return true;
    
        case 'stoch':
        case 'macd' : 
            if (params.length != 3) {
                vmsg = 'Invalid length of params: expected 3, received '+ params.length;
                return false;
            }
            for (var i in params) { 
                if(params[i].match(notnumeric)) { 
                    vmsg = 'parameter ' + params[i]+ ' is not in correct format';
                    return false; 
                } 
            }
            return true;
        
         case 'rsi': 
            if(params.length != 1) { 
                vmsg = 'Invalid length of params: expected 1, received '+ params.length;
                return false;
            } 
            if (params[0].match(notnumeric)) { 
                return false;
            } 
            return true;
         default:
            return false;
        }

        // if we come here, something is wrong, so let's return false
        vmsg = 'Unknown error'; 
        return false;
    }

    function setupUIHandlers() {
        $("#selectstyle").change(function (event) { 
            var style = parseInt($(this).val());
            var p = window.$plot;  
            if (!p) { return false;} // no plot yet 
            var sobj = (style? window.tickp.csdark:window.tickp.cslight); 
            if( sobj === p.cs) {
                return false; // do nothing;
            } else { 
                p.cs = sobj;
                p.plot();
            }
            return true; // used for chaining ?
        }); 
        $("#selecttype").change(function (event) { 
            var type = parseInt($(this).val());
            var p = window.$plot;
            if (!p) {return false;} // do nothing if no plot 
            p.cp.type = type;
            p.plot();
        }); 
        $("#selectmode").change(function (event) { 
            var mode = parseInt($(this).val());
            var p = window.$plot;
            if (!p) {return false;}
            p.changemode(mode);
        });
        $("#selectscale").change(function (event) { 
            var scale = parseInt($(this).val());
            var p = window.$plot;
            if (!p) { return false;}
            p.cp.logscale = !!scale;
            p.plot();
        });
        $("#zoomup").click(function(event) {
            var p = window.$plot;
            if(!p) return false;
            p.zoom(1);
        });
        $("#zoomdn").click(function(event) {
            var p = window.$plot;
            if(!p) return false;
            p.zoom(0);
        });

        $("#addind").click(function(event) { 
            var p = window.$plot; 
            if(!p) return false;        
        
            var type = $("#selectindicator").val(); 
            var paramstr = $("#paramtxt").val();

            //what we should get is comma separated list of values 
            var params = paramstr.replace(/[^0-9a-zA-Z,\.]+/g, '')
                            .split(',')
                            .map(function(i) {if(i) { return i.toLowerCase();} else { return null}}); 
            var n = []; 
            for (i in params) {
                if (params[i]) {
                    n.push(params[i]);
                }
            }
            if(validParams(type, n)) { 
                // We've params now, we validate those params and send it to $plot to plot. 
                p.addindicator(type, n);
                var ilist = p.getindicators();
                if(ilist.length) { 
                    var htmlstr = '';
                    for(var i in ilist) { 
                        htmlstr += "<option value=\"" + ilist[i]  + "\">" + ilist[i] + "</option>";   
                    } 
                    $("#selectcurrent").html(htmlstr);
                } 
            } else {
                alert(vmsg);
                return false;
            }
        });

        $("#delind").click(function(event) { 
            var which = $("#selectcurrent option:selected").val();
            var p = window.$plot;
            if(!p) return false;
            p.delindicator(which);
            var ilist = p.getindicators();
            var htmlstr = '';
            for(var i in ilist) { 
                htmlstr += "<option value=\"" + ilist[i]  + "\">" + ilist[i] + "</option>";   
            } 
            $("#selectcurrent").html(htmlstr);
        }); 
        
        $("#selectts").change(function(event) {
            var p = window.$plot;
            if(!p) return false; 
            var ts = parseInt($(this).val());
            p.setTimeScale(ts);
        
            
            return true;
        });

        $("#selectindicator").change(function(event) {
            defParams();
        });
    }; 
    $(document).ready(function() {
        scrips = undefined;
        if($.browser.msie) {
            if($.browser.version < "9.0") { 
                var htmlstr = '<h5> Your browser \'IE : ' + $.browser.version + '\' does not support certain HTML 5 features natively, which we use. You won\'t be able to experience the full capabilities without those. Workarouns include - Using <a href="http://code.google.com/chrome/chromeframe/">Google Chrome Frame</a> Plugin. To read more about \'Google Chrome Frame\' plugin, please read the following <a href="http://en.wikipedia.org/wiki/Google_Chrome_Frame"> article on Wikipedia</a>.' 
                $("#chart").html(htmlstr);
            }
        } 
            
        plot = window.tickp("#chart");
        plot.plotempty();
        $.ajax({
            url : '/scrips', 
            data : {},
            dataType : 'json', 
            type: 'GET', 
            success: function(data) {
                scrips = data;
                $("#scripselect").autocomplete(scrips, {
                    matchContains: true,
                    width:400, 
                    formatResult: function(row) {
                        return row.symbol;
                    },
		            formatItem: function(item) {
			            return item.symbol + ":" + item.name;
		            }
                });
            }
        });
        $("#stockget").click(function(event) {
            var symbol = $("#scripselect").val();
            var urlstr = '/sd?symbol=' + symbol;
            $.ajax({
                url : urlstr, 
                data : {},
                dataType : 'json', 
                type: 'GET', 
                success: function(data) { 
                    $("#loading").hide();
                    document.title = ' TickerPlot.com | ' + symbol;
                    var r = plot.read(data, function(d,e) { alert(e);});
                    if(!r) { 
                        return;
                    } 
                    plot.plot();
                }
            });
        });
        $("#loading").ajaxStart(function() {
            $(this).show();
        }).ajaxStop(function () {
            $(this).hide();
        });
        setupUIHandlers();
        defParams();
        setTimeout(function() { $("#scripselect").val('NIFTY'); $("#stockget").trigger('click');}, 200);
        $("#loading").hide();
        plot.getindicators();
    });
    </script>

<style> 
body {font-family: "Lucide Grande", Verdana, Lucida, Helvetica, Arial, sans-serif; font-size:10px;} 
#chart { margin:20px; } 
#scripselect {font-size:11px;}
#loading { position:absolute; left:250px; top:30px;z-index:500;} 
#getsymbol {margin-left:10px; display:inline;} 
#charttype {margin-left:10px; display:inline;} 
#timescale {margin-left:10px; display:inline;} 
#style {margin-left:10px; display:inline;} 
#mode {margin-left:10px; display:inline;} 
#scale {margin-left:10px; display:inline;} 
#zoom {margin-left: 10px; display:inline;}
#indicators {margin-left:10px; display:inline;} 
#current {margin-left:10px; display:inline;} 
.row {width:800px;margin:10px; display:block; } 
.chartoption {float:left;width:180px; height:40px;} 
.chartoption2 {float:left; width: 370px;} 
.chartoption3 {float: left;} 
#header {height:20px; border-bottom: 2px solid gray;}
#header .fltright {float:right; padding-right:5px;} 
#footer {text-align:center;border-top:1px solid gray;}
</style> 
</head>

<body>
<div id="header">
 <div class="fltright">
 <b>TickerPlot :</b> 
 <a href="/media/about.html">about </a> | <a href="/media/help.html">help</a> 
 </div>
</div> 
<div id=options">
    <div id="row1" class="row">
        <div id="getsymbol" class="chartoption"><b>Ticker:</b>
            <input type="text" id="scripselect" size="12"></input> 
            <input type="button" id="stockget" value="get"></input> 
            <div id="loading"> <img src="/media/ajax-loader.gif"></img></div>
        </div>
        <div id="timescale" class="chartoption"> <b>Interval:</b> 
            <select id="selectts">
                <option value="0">Daily</option>
                <option value="1">Weekly</option>
                <option value="2">Monthly</option>
            </select>
        </div>
        <div id="charttype" class="chartoption"> <b>Type:</b> 
            <select id="selecttype"> 
                <option value="1">Candlesticks</option>
                <option value="2">Bar charts</option>
                <option value="3">Line charts</option>
            </select>
        </div>
        <div id="style" class="chartoption"> <b>Style:</b> 
            <select id="selectstyle">
                <option value="1">Dark</option>
                <option value="0">Light</option>
            </select> 
        </div>
    </div>
    <div id="row2" class="row">
        <div id="mode" class="chartoption"> <b>Mode:</b> 
            <select id="selectmode">
                <option value="1">Pan and Zoom</option>
                <option value="0">Trendline</option>
            </select> 
        </div>
        <div id="scale" class="chartoption"> <b>Scale:</b> 
            <select id="selectscale">
                <option value="0">Linear</option>
                <option value="1">Log</option>
            </select> 
        </div>
        <div id="zoom" class="chartoption"><b>Zoom:</b>
            <input type="button" id="zoomup" value="+"></input>
            <input type="button" id="zoomdn" value="-"></input>
        </div>
    </div>
    <div id="row3" class="row">
        <div id="indicators" class="chartoption2"><b>Add Indicator:</b>
            <select id="selectindicator">
                <option value="ema">EMA</option>
                <option value="sma">SMA</option>
                <option value="psar">PSAR</option>
                <option value="bbands">Bollinger Bands</option>
                <option value="rsi">RSI</option>
                <option value="stoch">Stochastics</option>
                <option value="macd">MACD</option>
            <input type="text" id="paramtxt" size="12"></input> 
            <input type="button" id="addind" value="+"></input>
        </div>
        <div id="current" class="chartoption3"><b>Current Indicators:</b>
            <select id="selectcurrent"></select>
            <input type="button" id="delind" value="-"></input>
        </div>
    </div>
</div>
<div id="chart">
</div>
<div id="footer">
    Copyright &copy; 2010, TickerPlot.com 
</div>
</body>
</html>
