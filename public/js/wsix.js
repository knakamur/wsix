var onLoaders = [];
window.onload = function() { onLoaders.each(function(onLoader){onLoader();}); };
var onResizers = [];
window.onresize = function() { onResizers.each(function(onResizer){onResizer();}); };


var _width = 0; var _height = 0;
function showWindowDimensions() {
  if (wd = $('windowDimensions')) {
    wd.innerHTML = _width + " x " + _height;
  }
}
function setWindowDimensions() {
  if (typeof(window.innerWidth) == "number") {
    _width = window.innerWidth; _height = window.innerHeight;
  } else if (document.documentElement && document.documentElement.clientWidth) {
    _width = document.documentElement.clientWidth;
    _height = document.documentElement.clientHeight;
  } else if (document.body && document.body.clientWidth) {
    _width = document.body.clientWidth;
    _height = document.body.clientHeight;
  }
}
[onLoaders, onResizers].each(function(list){
  list.push(function() { setWindowDimensions(); showWindowDimensions(); });
});


var theWahmbulance = function() {
  if (window.innerWidth < 800 || window.innerHeight < 600) {
    alert("this site is designed to work at higher resolution than what you've got. "+
          "maybe try maximizing the browser window? i dunno dude...");
  }
}
onLoaders.push(theWahmbulance);


function validate(theForm, proc) {
  var result = { valid: true, errorBuf: "" };
  proc(theForm, result);
  if (result.valid) { 
    $('errors').innerHTML = "";
  } else {
    $('errors').innerHTML = result.errorBuf;
  }
  return result.valid;
}

function bad(result, msg) {
  result.valid = false;
  result.errorBuf = result.errorBuf + msg;
}
