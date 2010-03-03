function toggle(onOrOff) {
    var spans = document.getElementsByTagName("span");
    for (var i = 0; i < spans.length; i++) {
        if (spans[i].className != "nutria") {
            spans[i].className = onOrOff ? "tenhover" : "ten";
        }
    }
}
