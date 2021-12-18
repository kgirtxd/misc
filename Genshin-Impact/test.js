var data = "<p>This is 'myWindow'</p>";
myWindow = window.open("data:text/html," + encodeURIComponent(data),
                       "_blank", "width=200,height=100");
myWindow.focus();