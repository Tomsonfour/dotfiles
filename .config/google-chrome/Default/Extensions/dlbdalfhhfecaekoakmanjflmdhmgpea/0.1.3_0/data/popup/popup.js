var background = {
  "port": null,
  "message": {},
  "receive": function (id, callback) {
    if (id) {
      background.message[id] = callback;
    }
  },
  "send": function (id, data) {
    if (id) {
      chrome.runtime.sendMessage({
        "method": id,
        "data": data,
        "path": "popup-to-background"
      }, function () {
        return chrome.runtime.lastError;
      });
    }
  },
  "connect": function (port) {
    chrome.runtime.onMessage.addListener(background.listener); 
    /*  */
    if (port) {
      background.port = port;
      background.port.onMessage.addListener(background.listener);
      background.port.onDisconnect.addListener(function () {
        background.port = null;
      });
    }
  },
  "post": function (id, data) {
    if (id) {
      if (background.port) {
        background.port.postMessage({
          "method": id,
          "data": data,
          "path": "popup-to-background",
          "port": background.port.name
        });
      }
    }
  },
  "listener": function (e) {
    if (e) {
      for (let id in background.message) {
        if (background.message[id]) {
          if ((typeof background.message[id]) === "function") {
            if (e.path === "background-to-popup") {
              if (e.method === id) {
                background.message[id](e.data);
              }
            }
          }
        }
      }
    }
  }
};

var config = {
  "id": function (e) {
    const extension = document.getElementById("extension");
    extension.textContent = e.id;
  },
  "render": function (e) {
    const url = document.getElementById("url");
    const extension = document.getElementById("extension");
    /*  */
    url.value = e.url;
    extension.textContent = e.id;
  },
  "success": function () {
    const progress = document.querySelector(".progress");
    /*  */
    progress.value = 100;
    window.setTimeout(function () {
      progress.value = 0;
    }, 300);
  },
  "listener": {
    "download": function (e) {
      const url = document.getElementById("url");
      background.send("download", {
        "url": url.value,
        "format": e.target.id
      });
    }
  },
  "file": {
    "size": function (s) {
      if (s) {
        if (s >= Math.pow(2, 30)) {return (s / Math.pow(2, 30)).toFixed(1) + " GB"};
        if (s >= Math.pow(2, 20)) {return (s / Math.pow(2, 20)).toFixed(1) + " MB"};
        if (s >= Math.pow(2, 10)) {return (s / Math.pow(2, 10)).toFixed(1) + " KB"};
        return s + " B";
      } else {
        return '';
      }
    }
  },
  "error": function () {
    const crx = document.getElementById("crx");
    const zip = document.getElementById("zip");
    /*  */
    crx.setAttribute("error", '');
    zip.setAttribute("error", '');
    /*  */
    window.setTimeout(function () {
      crx.removeAttribute("error", '');
      zip.removeAttribute("error", '');
    }, 300);
  },
  "progress": function (e) {
    const status = document.querySelector(".status");
    const progress = document.querySelector(".progress");
    /*  */
    if ("message" in e) {
      status.textContent = e.message;
    }
    /*  */
    if ("total" in e && "loaded" in e) {
      const tmp = {};
      tmp.total = config.file.size(e.total);
      tmp.loaded = config.file.size(e.loaded);
      const percent = e.total ? e.loaded / e.total : e.loaded / 1000000;
      /*  */
      progress.value = Math.floor(percent * 100);
      status.textContent = (e.total ? tmp.loaded + " out of " + tmp.total : tmp.loaded) + " is downloaded, please wait...";
    }
  },
  "load": function () {
    const url = document.getElementById("url");
    const zip = document.getElementById("zip");
    const crx = document.getElementById("crx");
    const reload = document.getElementById("reload");
    const support = document.getElementById("support");
    const donation = document.getElementById("donation");
    /*  */
    zip.addEventListener("click", config.listener.download);
    crx.addEventListener("click", config.listener.download);
    reload.addEventListener("click", function () {background.send("reload")});
    support.addEventListener("click", function () {background.send("support")});
    donation.addEventListener("click", function () {background.send("donation")});
    url.addEventListener("change", function (e) {background.send("extract", {"url": e.target.value})});
    /*  */
    background.send("load");
    window.removeEventListener("load", config.load, false);
  }
};

background.receive("id", config.id);
background.receive("error", config.error);
background.receive("render", config.render);
background.receive("success", config.success);
background.receive("progress", config.progress);

window.addEventListener("load", config.load, false);
background.connect(chrome.runtime.connect({"name": "popup"}));
