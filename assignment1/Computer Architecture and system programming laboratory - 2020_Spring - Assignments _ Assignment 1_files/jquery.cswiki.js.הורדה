/**
 * CsWiki jQuery extenssion
 * */

(function($){

function getPageSize(){
  var de = document.documentElement;
  var w = window.innerWidth || self.innerWidth || (de&&de.clientWidth) || document.body.clientWidth;
  var h = window.innerHeight || self.innerHeight || (de&&de.clientHeight) || document.body.clientHeight;
  var t = (de&&de.scrollTop) || document.body.scrollTop;
  var l = (de&&de.scrollLeft) || document.body.scrollLeft;
  var sw =  (de&&de.scrollWidth) || document.body.scrollWidth;
  var sh =  (de&&de.scrollHeight) || document.body.scrollHeight;

  return {width:w, height:h, scrollTop:t, scrollLeft:l,
          wholeWidth: Math.max(w,sw), wholeHeight: Math.max(h,sh)};
};

$.fn.code =
  function(options){

  function toggle_code(e){
    $(e).css('min-height','20px');
    $(e).children('.code-toggle-area').toggle();
  };

  function get_code_source(e){
    var code = $(e).children('.hl-main').text();
    if(code == '') code = $(e).text();
    // remove unbrekable spaces
    code = code.replace(/\xA0/g,' ');

    var id = 'form-'+Math.random();
    var fname = $(e).attr('filename');
    $(document.body).append('<form action="'+options.base+'?" id="'+id+'" method="post">'+
                            '<input type="hidden" name="page" value="CsWiki.ShowCode" />'+
                            '<input type="hidden" name="format" value="raw" />'+
                            '<input type="hidden" name="code" value="'+escape(code)+'" />'+
                            (!!fname?'<input type="hidden" name="filename" value="'+fname+'" />':'')+
                            '</form>');
    document.getElementById(id).submit();
    $('#'+id).remove();
  };


  return this.each(function(){
    var $me = $(this);
    var extra = '';
    var fname = $(this).attr('filename');
    if(!fname){ fname = 'code.txt'; }

    var div = $('<div class="small float-right no-print"></div>').get(0);

    var collapse = false;
    var extra = false;
    if(fname){
      var a = $('<a></a>').click(function(){ get_code_source(this.parentNode.parentNode); }).get(0);
      $(a).append('<img src="'+options.imagesBase+'download.gif" alt="download" title="download '+fname+'"/>');
      $(div).append(a);
      extra = true;
    }

    var lines_div = undefined;
    if($me.height() > 200){
      var a = $('<a></a>').click(function(){ toggle_code(this.parentNode.parentNode); }).get(0);
      $(a).append('<img align="top" src="'+options.imagesBase+'toggle.gif" alt="toggle" title="toggle"/>');
      $(div).append(a);
      extra = true;
      var match = $me.text().match(/(\x0D|\x0A)/g);
      if(match){
        var lines = $me.text().match(/(\x0D|\x0A)/g).length;
        lines_div = $('<div class="code-toggle-area center gray">'+lines+' lines ...</div>').hide().get(0);
      }
      if($me.attr('close') != undefined){ 
        collapse = true;
      }
    }

    if(extra){
      $me.wrapInner('<div class="code-toggle-area"></div>');
      if(lines_div != undefined){
        $me.prepend(lines_div);
      }
      $me.prepend(div);
    }
    if(collapse){
      toggle_code(this);
    }
  });

  };


$.fn.collapsible = function(){
  var plus_img = jQuery.ImagesBase+'button-plus.gif';
  var minus_img = jQuery.ImagesBase+'button-minus.gif';
  var collapse = $(this).attr('closed') != undefined;

  $(this).
    css({'list-style':'none',
         'margin-left':'14px'}).
    children('li').each(function(){
    var $me = $(this);
    var $uls = $me.children('ul');
    $me.css({'list-style-image':'none'});
    if($uls.length>0){
      var img = $('<img src="'+(collapse?plus_img:minus_img)+'" class="hand"/>').
                css({'margin-left':'-14px',
                     'padding-right':'1px'}).
                click(function(){
                  $uls.slideToggle('fast',
                                   function(){
                                     if($(img).attr('src') == plus_img)
                                       $(img).attr('src',minus_img);
                                     else
                                       $(img).attr('src',plus_img);
                                   });
              }).
              get(0);
      //$($uls.get(0)).before(a);
      $me.prepend(img);
      $uls.collapsible(collapse);
      if(collapse)
        $uls.hide();
    }
  });
};

var dark = undefined;

$.screenOff = function(){
  if(dark == undefined){
    dark = $('<div></div>').get(0);
    $(dark).css({'position':'absolute', 
                 'left':0, 'top':0 , 
                 'width':'100%', 
                 'min-height': '100%',
                 'text-align': 'center',
                 'background-color':'black', 
                 'opacity':'0.20', 'filter':'alpha(opacity=20)' });
    $('body').append(dark);
  }
  var ps = getPageSize();
  $(dark).css({'left':0, 'top':0 , 
               'width':'100%', 
               'height': ps.wholeHeight });
  $(dark).show();
};

$.screenOn = function(){
  if(dark != undefined){
    $(dark).hide();
  }
};


$.loadPage = function(url,opt){
  $.screenOff();
  var ps = getPageSize();
  var height = Math.floor(ps.height*0.9);
  var div = $('<div class="popup"></div>').css({'display':'none','height':height}).get(0);

  var a = $('<a class="huge">back</a>').click(function(){ $(div).remove(); $.screenOn(); });
  $(div).append(a);
  var content = $('<div></div>').get(0);
  $(div).append(content);
  $('body').append(div);
  $(content).load(url+' #main',{},
                  function(){ 
                    $(this).css({'overflow':'auto','height':'90%','min-height':'auto'});
                  });

  $(div).css({'left' : Math.floor((ps.width - $(div).width())/2 + 2),
              'top' : ps.scrollTop + Math.floor((ps.height - $(div).height())/2) }).show();
};

$.showCode = function(code){
  $.screenOff();
  var ps = getPageSize();
  var height = Math.floor(ps.height*0.9);
  var div = $('<div class="popup"></div>').css({'display':'none','height':height}).get(0);

  var a = $('<a></a>').click(function(){ $(div).remove(); $.screenOn(); }).
          append('<img src="'+jQuery.ImagesBase+'button-close.gif" alt="close" title="close"/>');
  $(div).append(a);
  var content = 
    $('<pre class="code"></pre>').
    css({'overflow':'auto','height':'90%','min-height':'auto'}).
    text(unescape(code)).
    get(0);
  $(div).append(content);
  $('body').append(div);
  $(div).css({'left' : Math.floor((ps.width - $(div).width())/2 + 2),
              'top' : ps.scrollTop + Math.floor((ps.height - $(div).height())/2) }).show();
};

$.showPreview = function(form,action){
  if(!action){
    action = 'preview';
  }

  $.screenOff();
  var ps = getPageSize();
  var height = Math.floor(ps.height*0.9);
  var div = $('<div class="popup"></div>').css({'display':'none','height':height}).get(0);

  var a = $('<a></a>').
          css({'display':'block','text-align':'right'}).
          click(function(){ $(div).remove(); $.screenOn(); }).
          append('<img src="'+jQuery.ImagesBase+'button-close.gif" alt="close" title="close"/>');
  $(div).append(a);
  var content = 
    $('<iframe name="preview_frame">Loading preview ...</iframe>').
    css({'display':'block','overflow':'auto','width':'100%','height':'95%','min-height':'auto','border':'none'}).
    get(0);
  $(div).append(content);
  $('body').append(div);
  $(div).css({'left' : Math.floor((ps.width - $(div).width())/2 + 2),
              'top' : ps.scrollTop + Math.floor((ps.height - $(div).height())/2) }).show();
  act(form,action,'preview_frame');
};

var colors = [
   ["#FFFFFF","#FFCCCC","#FFCC99","#FFFF99","#FFFFCC","#99FF99","#99FFFF","#CCFFFF","#CCCCFF","#FFCCFF"],
   ["#CCCCCC","#FF6666","#FF9966","#FFFF66","#FFFF33","#66FF99","#33FFFF","#66FFFF","#9999FF","#FF99FF"],
   ["#C0C0C0","#FF0000","#FF9900","#FFCC66","#FFFF00","#33FF33","#66CCCC","#33CCFF","#6666CC","#CC66CC"],
   ["#999999","#CC0000","#FF6600","#FFCC33","#FFCC00","#33CC00","#00CCCC","#3366FF","#6633FF","#CC33CC"],
   ["#666666","#990000","#CC6600","#CC9933","#999900","#009900","#339999","#3333FF","#6600CC","#993399"],
   ["#333333","#660000","#993300","#996633","#666600","#006600","#336666","#000099","#333399","#663366"],
   ["#000000","#330000","#663300","#663333","#333300","#003300","#003333","#000066","#330099","#330033"],
   ];
colors = [
  ["#EEEEEE","#FFFF88","#CDEB8B","#C3D9FF","#36393D"],
  ["#FF1A00","#CC0000","#FF7400","#008C00","#006E2E"],
  ["#4096EE","#FF0084","#B02B2C","#D15600","#C79810"],
  ["#73880A","#6BBA70","#3F4C6B","#356AA0","#D01F3C"]
  ];
colors = 
  [
  ["#CC3333","#DD4477","#994499","#6633CC","#336699","#3366CC","#22AA99"],
  ["#329262","#109618","#66AA00","#AAAA11","#D6AE00","#EE8800","#DD5511"],
  ["#A87070","#8C6D8C","#627487","#7083A8","#5C8D87","#898951","#B08B59"],
  ["#CCCCCC","#AAAAAA","#888888","#666666","#444444","#222222","#000000"]
  ]
  /*
  [
  ["#A32929","#CC3333","#D96666","#E69999","#F0C2C2"],
  ["#B1365F","#DD4477","#E67399","#EEA2BB","#F5C7D6"]
  ["#7A367A","#994499","#B373B3","#CCA2CC","#E1C7E1"],
  ["#5229A3","#6633CC","#8C66D9","#B399E6","#D1C2F0"],
  ["#29527A","#336699","#668CB3","#99B3CC","#C2D1E1"],
  ["#2952A3","#3366CC","#668CD9","#99B3E6","#C2D1F0"],
  ["#1B887A","#22AA99","#59BFB3","#91D5CC","#BDE6E1"],
  ["#28754E","#329262","#65AD89","#99C9B1","#C2DFD0"],
  ["#0D7813","#109618","#4CB052","#88CB8C","#B8E0BA"],
  ["#528800","#66AA00","#8CBF40","#B3D580","#D1E6B3"],
  ["#88880E","#AAAA11","#BFBF4D","#D5D588","#E6E6B8"],
  ["#AB8B00","#D6AE00","#E0C240","#EBD780","#F3E7B3"],
  ["#BE6D00","#EE8800","#F2A640","#F7C480","#FADCB3"],
  ["#B1440E","#DD5511","#E6804D","#EEAA88","#F5CCB8"],
  ["#865A5A","#A87070","#BE9494","#D4B8B8","#E5D4D4"],
  ["#705770","#8C6D8C","#A992A9","#C6B6C6","#DDD3DD"],
  ["#4E5D6C","#627487","#8997A5","#B1BAC3","#D0D6DB"],
  ["#5A6986","#7083A8","#94A2BE","#B8C1D4","#D4DAE5"],
  ["#4A716C","#5C8D87","#85AAA5","#AEC6C3","#CEDDDB"],
  ["#6E6E41","#898951","#A7A77D","#C4C4A8","#DCDCCB"],
  ["#8D6F47","#B08B59","#C4A883","#D8C5AC","#E7DCCE"]
  ];
  */
function createPalette(default_color){
  var palette = $('<div style="display:none;position:absolute;background-color:#aaa;padding:1px;font-size:1px;font-family:mono;"></div>').
                get(0);
  var content = '';
  for(var i=0;i<colors.length;i++){
    for(var j=0;j<colors[i].length;j++){
      var c = colors[i][j];
      content += '<div style="float:left; background-color:'+c+';'+
                 'width:15px; height:15px; border:1px '+(c==default_color?'dotted':'solid')+' white; margin:1px;"'+
                 ' class="palette-color hand" title="'+c+'">'+
                 '&nbsp;'+
                 '</div>';
    }
    content += '<br style="clear:both"/>';
  }
  $(palette).append(content);
  $('body').append(palette);
  return palette;
};
$.fn.showPalette = function(){
  var $me = $(this);
  
  if($me.attr('use_palette') == 'true') return;
  else $me.attr('use_palette','true');

  var hidePalette = function(){ 
    $(palette).hide(); 
  };

  var setColor = function(){
    var color = $(this).attr('title');
    $(palette).children('.palette-color').css('border-style','solid');
    $(this).css('border-style','dotted');
    $me.val(color);
    $(btn).css('background-color',color);
    hidePalette();
  };

  var click = function(){
    if($(palette).filter(':visible').length == 1)
      hidePalette();
    else{
      $(palette).show();
      //setTimeout(hidePalette,5000);
    }
  };
  
  var color = $me.val()!='' ? $me.val() : 'white';
  var palette = createPalette(color);
  $(palette).children('.palette-color').unbind('click').click(setColor);
  
  var off = $me.offset();
  var btn = $('<div></div>').
            attr('title','choose color').
            addClass('hand').
            css({ 'position':'absolute',
                  'left': off.left + $me.width() - $me.height(),
                  'top': off.top+2,
                  'height':$me.height(), 'width':$me.height(),
                  'background-color': color,
                  'border':'1px solid black'}).
            click(click).
            get(0);
  $me.after(btn);

  off = $(btn).offset();
  $(palette).css({'left':off.left,'top':off.top+$(this).height()+2});

  $me.keydown(function(e){ if(e.which == 27) hidePalette(); });

  };

})($);
