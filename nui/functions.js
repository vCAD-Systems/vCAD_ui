var lastSite = "https://pc.copnet.li";

$(document).ready(function() {
    var $iframe = $("#iframe")[0];
    var $tabContainer = $("#tab-container");
    var $tabWrap = $(".tab-wrap");
    // Show or hide the page
    function SHOW_HIDE(bool) {
        $("#tab-container").css("display", "none");
        $("#tab-container-flixxx").css("display", "none");
        
        if (bool) {
            $tabContainer.show();
        } else {
            $tabContainer.hide();
            window.blur(); // unfocus the window
        }
    }
    SHOW_HIDE(false); // hide the tablet initial
    // Listens for NUI messages from Lua 
    window.addEventListener('message', function(event) {
        var item = event.data;

        if (item.showtab) {
            if (item.site) {
                lastSite = item.site;
                $iframe.src = item.site;

                if (item.design == true) {
                    tabContainer = $("#tab-container-flixxx");
                } else {
                    tabContainer = $("#tab-container");

                    if (item.autoscale == true) {
                        $tabWrap.css("width", "65%");
                        $tabWrap.css("max-width", "65%");
                        $tabWrap.css("max-height", "70%");
                        $tabWrap.css("min-height", "70%");
                    } else {
                        $tabWrap.css("width", "100%");
                        $tabWrap.css("max-width", "100%");
                        $tabWrap.css("max-height", "95%");
                        $tabWrap.css("min-height", "95%");
                    }
                }

                SHOW_HIDE(true)
            }
        } else if (item.hidetab) {
            SHOW_HIDE()
        }
    });
    // When pressed ESC dispatch escape request
    document.addEventListener('keyup', function (data) {
        if (data.which == 27) {
            SHOW_HIDE(); // hide ui
            $.post(`http://${GetParentResourceName()}/tablet-bus`, JSON.stringify({
                hide: true
            })) // tell lua to unfocus
        }
    });
    // When clicked the dot
    $('.dot#off').click(function() {
        SHOW_HIDE(); // hide ui
        $.post(`http://${GetParentResourceName()}/tablet-bus`, JSON.stringify({
            hide: true
        })) // tell lua to unfocus
    });
    $('.dot#reset').click(function() {
        $iframe.src = lastSite;
    });
    // Tell lua the nui loaded
    $.post(`http://${GetParentResourceName()}/tablet-bus`, JSON.stringify({
        load: true
    }))
});
