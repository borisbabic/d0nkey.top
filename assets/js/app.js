// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
// import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
import "phoenix_html"

import Alpine from 'alpinejs'
window.Alpine = Alpine
Alpine.start()

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import '@fortawesome/fontawesome-free/js/all'

// <NITROPAY_ADBLOCK_DETECTION>
var dispatchNpBlocking = function (blocking) {
    if (document.dispatchEvent && window.CustomEvent) {
        document.dispatchEvent(
            new CustomEvent('np.blocking', {
                detail: {
                    blocking: blocking,
                },
            })
        );
    }

}
var npDetect = new (function () {
    this.blocking = false;
    var errcnt = 0;
    function testImg() {
        var i = new Image();
        i.onerror = () => {
            errcnt++;
            if (errcnt < 3) {
                setTimeout(testImg, 250);
            } else {
                npDetect.blocking = true;
                dispatchNpBlocking(npDetect.blocking);

            }
        };
        i.onload = () => {
            npDetect.blocking = false;
        };

        i.src = 'https://s.nitropay.com/1.gif?' + Math.random() + '&adslot=';
    }
    testImg();
})();
// </NITROPAY_ADBLOCK_DETECTION>
document.addEventListener('DOMContentLoaded', () => {
    if (!window['nads']) {
        dispatchNpBlocking(true);
    }
});
document.addEventListener('np.blocking', (e) => {
    if (e.detail.blocking) {
        console.log("Ad blocking detected. Would you mind turning it off? If not, I understand");
        var to_show = document.getElementsByClassName("is-shown-ad-blocking")
        for (var e of to_show) {
            console.log("changing display");
            console.log("changing display", e);
            e.style.display = "block";
        }
    } else {
        console.log("No ad blocking detected");
    }
});

var clipboard = new ClipboardJS(".clip-btn-value");
clipboard.on('success', function(e) {
    console.log("Text we are copying is: " + e.text)
    if (e.text && e.action === "copy" && e.trigger.hasAttribute("data-aria-on-copy")) {
        e.trigger.setAttribute("aria-label", e.trigger.getAttribute( "data-aria-on-copy"))
    }
})
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
            if (Number.isInteger(date.getMonth())) {
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
window.canCloseDropdown = function(event) {
    var skipElement = function(element) {
        return element && (element.className == "report-link" || element.nodeName == "iframe")
    }
    return !skipElement(event.target) && !skipElement(event.relatedTarget);
}

window.uncheck = function(target_class) {
    var elements = document.getElementsByClassName(target_class);
    Array.prototype.forEach.call(elements, function (thing) {
        thing.checked = false;
    });
    return false;
}
window.hide_based_on_search = function(search_id, target_class)  {
    var input = document.getElementById(search_id);
    if (input) {
        console.log("Searching for " + input.value);
        var elements = document.getElementsByClassName(target_class);
        Array.prototype.forEach.call(elements, function (thing) {
            if (input.value === null || thing.dataset && thing.dataset.targetValue && thing.dataset.targetValue.toLowerCase().search(input.value.toLowerCase()) > -1) {
                thing.style.display = "";
            }
            else {
                thing.style.display="none";
            }
        })
    }
    else {
        console.log("Could not find search")
    }
}

window.set_display = function (id_or_elem, display_val) {
    var elem = id_or_elem;
    if(typeof(id_or_elem) === "string" || id_or_elem instanceof String){
        elem = document.getElementById(id_or_elem);
    }

    if(elem && elem.style) {
        elem.style.display = display_val;
    } else {
        console.log("Can't set display on elem")
    }
}

/**** <LiveViewCopyPasta> ****/
// assets/js/app.js
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
    params: {_csrf_token: csrfToken},
    dom: {
        onBeforeElUpdated(from, to){
          if(from._x_dataStack){
            window.Alpine.clone(from, to) ;
          }
        }
    }
})

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
