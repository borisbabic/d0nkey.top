// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import '@fortawesome/fontawesome-free/js/all'


new ClipboardJS(".clip-btn-value", {text: function(trigger) {
    return trigger.getAttribute("aria-label");
}});
document.addEventListener('DOMContentLoaded', () => {
    var hideWithJs = document.getElementsByClassName("is-shown-js")
    for (var i = 0; i < hideWithJs.length; i++) {
        hideWithJs[i].style.display = "";
    }
})

document.addEventListener('DOMContentLoaded', () => {
    console.log("Converting datetimes")
    var pad = function(te) {
        return ('0' + te).slice(-2)
    }
    var toConvert = document.getElementsByClassName("datetime-human")
    for (var i = 0; i < toConvert.length; i++) {
        try {
            var timestamp = toConvert[i].getAttribute("aria-label");
            var date = new Date(parseInt(timestamp));
            if (date.getMonth()) {
                toConvert[i].innerHTML =
                    [date.getFullYear(), pad(date.getMonth() + 1), pad(date.getDate())].join('-')
                    + ' '
                    + [ pad(date.getHours()), pad(date.getMinutes()), pad(date.getSeconds())].join(':')
            }
        }
        catch(e){ }
    }
})


window.location_href_by_datalist = function(input_id, datalist_id) {
    var input = document.getElementById(input_id)
    if(input && input.value) {
        var option = document.querySelector('option[value="' + input.value + '"]');
        if (option && option.dataset && option.dataset.link) {
            window.location.href = option.dataset.link

        } else {
            console.log("Can't location href, no option or option link")
        }
    } else {
        console.log("Can't location href, no input or input value")
    }
}

/**** <LiveViewCopyPasta> ****/
// assets/js/app.js
import {Socket} from "phoenix"
import LiveSocket from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Connect if there are any LiveViews on the page
liveSocket.connect()

// Expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)
// The latency simulator is enabled for the duration of the browser session.
// Call disableLatencySim() to disable:
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
/**** </LiveViewCopyPasta> ****/
