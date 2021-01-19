$(document).ready(function () {
    var iframe = $("#iframe")[0];
    var $tabContainer = $("#tab-container");
    var $tabWrap = $(".tab-wrap");
    // Show or hide the page
    function SHOW_HIDE(bool) {
        if (bool) {
            $tabContainer.show();
        } else {
            $tabContainer.hide();
            window.blur() // unfocus the window
        }
    }
    SHOW_HIDE(false); // hide the tablet initial
    // Listens for NUI messages from Lua 
    window.addEventListener('message', function (event) {
        var item = event.data;
        if (item.showtab) {
            if (item.site) {
                iframe.src = item.site;

                if (item.autoscale == true) {
                    $tabWrap.css("width", "65%")
                    $tabWrap.css("max-width", "65%")
                    $tabWrap.css("max-height", "70%")
                    $tabWrap.css("min-height", "70%")
                } else {
                    $tabWrap.css("width", "100%")
                    $tabWrap.css("max-width", "100%")
                    $tabWrap.css("max-height", "95%")
                    $tabWrap.css("min-height", "95%")
                }
            }

            SHOW_HIDE(true)
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
    $('.tab-wrap .dot').click(function () {
            SHOW_HIDE(); // hide ui
            $.post(`http://${GetParentResourceName()}/tablet-bus`, JSON.stringify({
                hide: true
            })) // tell lua to unfocus
    });
    // Handle icon click
    $('a.nav-myframe').click(function (event) {
        event.preventDefault();
        event.stopPropagation();
        var self = this;
        var icon = $(self).find("img, .myicon");
        icon.addClass("jump")
        // bounce dat ass
        setTimeout(function () {
            iframe.src = self.href || "about:blank"; // trigger HandleLocationChange
            icon.removeClass("jump");    
        }, 600)
        return false;
    });
    // Tell lua the nui loaded
    $.post(`http://${GetParentResourceName()}/tablet-bus`, JSON.stringify({
        load: true
    }))
});