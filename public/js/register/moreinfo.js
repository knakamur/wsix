function submitDance(theForm) {
  if (!(validate(theForm, validateMoreInfo))) {
    return false;
  }
  return true;
}

var validateMoreInfo = function(theForm, result) {
  var re = new RegExp(/^\d+$/);
  var years = theForm[9].value;
  var numbr = theForm[11].value;

  // years worked is an integer?
  if (years != "" && !(re.match(years))) {
    bad(result, "the number of years you've worked has to be a *number*.<br/>");
  }

  // number requested is an integer?
  if (numbr != "" && !(re.match(numbr))) {
    bad(result, "the racer number you want has to be a *number*.<br/>");
  }

};

function flipShirtSize(bool) {
  if (bool || $('shirtRequested').disabled) {
    $('shirtSize').disabled = true;
    $('shirtSizeLabel').style.color = "#aaa";
  } else {
    $('shirtSize').disabled = false;
    $('shirtSizeLabel').style.color = "#224";
  }

}
