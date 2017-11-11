editor = null
currentmode = ''
ajaxURL = 'http://' + location.host

//alert (ajaxURL)

function getmode(mode) {
    $.get(ajaxURL + '/get_mode/' + mode, function(data) {
        editor.setValue(data)
        editor.gotoLine(1)
        currentmode = mode
        $("#title").html(mode)
    });
}

function getmodeList() {
     $.getJSON(ajaxURL + '', function(data) {
        $("#modees").empty();
        $.each(data, function (i,v) {
          
            $mode = $('<div class="side-button"></div>').append(v);
            $mode.click(function () {
                getmode(v);
            });
           $("#modees").append($mode);
        });
    });
}

function saveNewmode() {
    
    newName = prompt('Enter New Name (No Spaces!)')

    if (newName == null) {
        alert('f');
    }

    $.post(ajaxURL + "/save_new", { name: newName, contents: editor.getValue() })
    .done(function(data) {
        // reload mode list
        getmodeList();
         // alert(data);
    });
}

function savemode() {
    
    $.post(ajaxURL + "/save", { name: currentmode, contents: editor.getValue() })
    .done(function(data) {
         // alert(data);
    });
}

function sendReload() {
    
    //$.post(ajaxURL + "/send_reload", { name: currentmode, contents: editor.getValue() })
    $.post(ajaxURL + "/send_reload", {name: currentmode })
    .done(function(data) {
         // alert(data);
    });
}

$(document).ready(function() {


    // this disables page while loading things 
    $("body").on({
        // When ajaxStart is fired, add 'loading' to body class
        ajaxStart: function() { 
            $(this).addClass("loading"); 
        },
        // When ajaxStop is fired, rmeove 'loading' from body class
        ajaxStop: function() { 
            $(this).removeClass("loading"); 
        }    
    });

        
    editor = ace.edit("editor");
    editor.setTheme("ace/theme/merbivore_soft");
    editor.getSession().setMode("ace/mode/python");
    //$("#editor").style.fontSize='16px';
    document.getElementById('editor').style.fontSize='14px';
    getmodeList();

    $("#clear-screen").click(function() {
        sendCmd("cs\n");
    });

    $("#screengrab").click(function() {
        sendCmd("screengrab\n");
    });


    $("#reload-mode").click(function() {
        sendReload();
    });


    $("#osd-toggle").click(function() {
        sendCmd("osd\n");
    });

    $("#quit").click(function() {
        sendCmd("quit\n");
    });



    $("#save-new").click(function() {
        saveNewmode();
    });



    $("#save").click(function() {
        savemode();
    });

});
