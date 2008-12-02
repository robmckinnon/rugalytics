// ==UserScript==
// @name           rugrat
// @namespace      github.com/robmckinnon/rugalytics
// @description    a mousehole to google analytics data
// @include        http://your_website/*
// ==/UserScript==

window.Rugrat = function() {;}

window.Rugrat.prototype = {

  replace_all: function(text, old, replace) {
    while(text.indexOf(old) > 0) { text = text.replace(old,replace); }
    return text;
  },

  keyword_grab: function(keywords, keyword_id, segment) {
    var the_url = "http://localhost:8888/keyword_detail?keywords="+keywords+"&segment="+segment;
    GM_log(the_url);
    var base = this;
    GM_xmlhttpRequest({
       method:"GET",
       url: the_url,
       headers:{
         "User-Agent":"Mozilla/5.0",
         "Accept":"application/json"
       },
       onload:function(response) {
         var status = base.replace_all(response.statusText,' ','');
         if (status == 'OK') {
           var json = response.responseText;
           var data = eval('(' + json + ')');
           base.display_keywords(data, keyword_id, segment);
         }
       }
     });
  },

  display_keywords: function(data, keyword_id, segment) {
    var items = data.items;
    var comma = '';
    for (var i in items) {
      var item = items[i];
      var name = 'red';

      if (segment == 'city') {
        name = item.city;
      } else {
        name = item.network_location;
      }
      if (segment == 'city' || (name.indexOf('mini') >= 0 || name.indexOf('trea') >= 0) ) {
        var element = document.getElementById(keyword_id);
        var html = element.innerHTML;
        element.innerHTML = html + comma + ' <small>'+ name +'</small>';
        comma = ',';
      }
    }
  },

  data_grab: function() {
    var pathname = window.location.pathname;
    var the_url = "http://localhost:8888/top_content_detail_keywords?url="+pathname;
    GM_log(the_url);
    var base = this;
    GM_xmlhttpRequest({
       method:"GET",
       url: the_url,
       headers:{
         "User-Agent":"Mozilla/5.0",
         "Accept":"application/json"
       },
       onload:function(response) {
         var status = base.replace_all(response.statusText,' ','');
         if (status == 'OK') {
           var json = response.responseText;
           var data = eval('(' + json + ')');
           base.display_data(data);
         }
       }
     });
  },

  grab_unique_page_views: function() {
    var pathname = window.location.pathname;
    var the_url = "http://localhost:8888/top_content_detail?value=unique_pageviews&url="+pathname;
    GM_log(the_url);
    var base = this;
    GM_xmlhttpRequest({
       method:"GET",
       url: the_url,
       headers:{
         "User-Agent":"Mozilla/5.0",
         "Accept":"application/json"
       },
       onload:function(response) {
         var status = base.replace_all(response.statusText,' ','');
         if (status == 'OK') {
           var json = response.responseText;
           var data = eval('(' + json + ')');
           base.display_unique_page_views(data);
         }
       }
     });
  },

  display_unique_page_views: function(data) {
    var visits = data.unique_pageviews_graph.points;
    var max = Math.max.apply( Math, visits) * 1.2;
    var points = visits.join(',');
    var sparkline = 'http://chart.apis.google.com/chart?chs=200x40&cht=ls&chds=0,' + max + '&chco=0077CC&chm=B,E6F2FA,0,0,0&chls=1,0,0&chd=t:'+points;
    var img = '<img style="vertical-align: middle;border: none;width:200px; height:40px;" src="' + sparkline + '"></img>';

    var element = document.getElementById("r_unique_page_views");
    element.innerHTML = img + ' ' + data.unique_pageviews_total;
  },

  display_data: function(data) {
    var lines = '';

    lines += '<h3 style="margin-top: 0.5em;">Unique Page Views</h3>';
    lines += '<span id="r_unique_page_views" style="width:200px; height:40px;"></span>';
    lines += '<h3 style="margin-top: 0.5em;">Entrance keywords</h3>';

    for (var i in data.items) {
      var item = data.items[i];
      var url = '';
      var keywords = item.keyword;
      lines += '<p id="x' + i + '" style="margin : 0.5em; font-size: 0.75em"><a href="'+url+'" style="text-decoration: none;">' + keywords + '</a> (' + item.unique_pageviews + ')</p>';
    }

    var menudiv = document.createElement('div');
    menudiv.style.position = 'fixed';
    menudiv.style.top = '5px';
    menudiv.style.left = '55%';
    menudiv.style.padding = '10px';
    menudiv.style.backgroundColor = '#fff';
    menudiv.style.border="2px solid";
    menudiv.zIndex = '3';
    // menudiv.style.display='none';

    var menuobj = document.createElement('div');
    menuobj.innerHTML = lines;
    menudiv.appendChild(menuobj);

    var content = document.getElementById('content');
    content.appendChild(menudiv);

    this.grab_unique_page_views();
    for (var i in data.items) {
      var keywords = data.items[i].keyword;
      this.keyword_grab(keywords, 'x'+i, 'city');
      this.keyword_grab(keywords, 'x'+i, 'organization');
    }
  },

  init: function() {
    this.data_grab();
  }
};

window.addEventListener("load", function () {
  var ahole = new window.Rugrat();
  ahole.init();
}, false);

