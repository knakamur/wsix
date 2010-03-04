function submitDance(theForm) {
  if (!(validate(theForm))) {
    return false;
  }
  theForm.password_hash.value =
    hex_md5(theForm.password.value + theForm.password_salt.value);
  return true;
}

function validate(theForm) {
  var valid = true;
  var errorSpan = document.getElementById("errors");
  var errorBuf = "";

  // check email address
  if (!(isRFC822ValidEmail(theForm.email.value))) {
    valid = false;
    errorBuf = errorBuf + "<b>email address</b> is not valid.<br/>";
  }

  // check password
  if (!(theForm.password.value.length >= 6)) {
    valid = false;
    errorBuf = errorBuf + "<b>password</b> is not long enough (needs 6 or more).<br/>";
  }

  // check confirmation matches password
  if (theForm.pw_conf.value != theForm.password.value) {
    valid = false;
    errorBuf = errorBuf + "<b>passwords</b> don't match.<br/>";
  }

  if (valid) { 
    errorSpan.innerHTML = "";
  } else {
    errorSpan.innerHTML = errorBuf;
  }
  return valid;
}

// thanks to rosskendall.com
function isRFC822ValidEmail(sEmail) {
  var sQtext = '[^\\x0d\\x22\\x5c\\x80-\\xff]';
  var sDtext = '[^\\x0d\\x5b-\\x5d\\x80-\\xff]';
  var sAtom = '[^\\x00-\\x20\\x22\\x28\\x29\\x2c\\x2e\\x3a-\\x3c\\x3e\\x40\\x5b-\\x5d\\x7f-\\xff]+';
  var sQuotedPair = '\\x5c[\\x00-\\x7f]';
  var sDomainLiteral = '\\x5b(' + sDtext + '|' + sQuotedPair + ')*\\x5d';
  var sQuotedString = '\\x22(' + sQtext + '|' + sQuotedPair + ')*\\x22';
  var sDomain_ref = sAtom;
  var sSubDomain = '(' + sDomain_ref + '|' + sDomainLiteral + ')';
  var sWord = '(' + sAtom + '|' + sQuotedString + ')';
  var sDomain = sSubDomain + '(\\x2e' + sSubDomain + ')*';
  var sLocalPart = sWord + '(\\x2e' + sWord + ')*';
  var sAddrSpec = sLocalPart + '\\x40' + sDomain; // complete RFC822 email address spec
  var sValidEmail = '^' + sAddrSpec + '$'; // as whole string

  var reValidEmail = new RegExp(sValidEmail);

  if (reValidEmail.test(sEmail)) {
    return true;
  }

  return false;
}

var showing = "Start";
function snh(toShow, toHide) {
  if (showing == toHide) {
    Effect.Fade('register' + toHide, { duration: 0.25 });
    setTimeout("Effect.Appear('register" + toShow + "')", 250);
    $('show' + toHide).className = "tab inactive";
    $('show' + toShow).className = "tab active";
    setTimeout(function(){$('register' + toShow).select("input")[0].focus();}, 300);
    showing = toShow;
  }
}
