var core = {
  "start": function () {
    core.load();
  },
  "install": function () {
    core.load();
  },
  "load": function () {
    /*  */
  },
  "extract": {
    "id": function (url) {
      if (url) {
        if (url.indexOf("http") === 0) {
          let result = config.regx.url.exec(url);
          if (result && result.length) {
            if (result[2]) {
              let id = result[2];
              if (id) {
                return id;
              }
            }
          }
        } 
      }
      /*  */
      return null;
    }
  },
  "action": {
    "storage": function (changes, namespace) {
      /*  */
    },
    "error": function () {
      app.popup.send("error");
      config.extension.progress = false;
    },
    "success": function (tag) {
      app.popup.send("success");
      config.extension.progress = false;
      /*  */
      app.popup.post("progress", {
        "message": "Download complete! " + tag + " file is ready.",
      });
    },
    "process": function (url) {
      const id = core.extract.id(url);
      if (id) {
        app.popup.send("render", {"id": id, "url": url});
      } else {
        app.popup.send("render", {"id": "N/A", "url": ''});
      }
    },
    "download": function (url, format) {
      config.extension.id = core.extract.id(url);
      if (config.extension.id) {
        app.popup.post("progress", {
          "message": "Preparing to download, please wait...",
        });
        /*  */
        config.version.current = config.version.browser();
        if (config.version.current) {
          config.version.final = config.version.current.major + '.' + config.version.current.minor + '.' + config.version.current.build + '.' + config.version.current.patch;
          if (config.version.final) {
            if (format === "crx") {
              const a = "%26uc&acceptformat=crx2,crx3";
              const b = config.download.base + "?response=redirect&prodversion=";
              const c = config.version.final + "&acceptformat=crx2,crx3&x=id%3D" + config.extension.id;
              /*  */
              config.download.as.crx((b + c + a), config.extension.id, function () {
                core.action.success("CRX");
              });
            } else if (format === "zip") {
              const a = config.version.final + "&x=id%3D" + config.extension.id;
              const b = config.download.base + "?response=redirect&prodversion=";
              const c = "%26installsource%3Dondemand%26uc&acceptformat=crx2,crx3";
              /*  */
              config.extension.fetch((b + a + c), function (blob) {
                config.download.as.zip(blob, config.extension.id, function () {
                  core.action.success("ZIP");
                });
              });
            }
            /*  */
            return;
          }
        }
      }
      /*  */
      core.action.error();
    },
    "popup": {
      "download": function (e) {
        core.action.download(e.url, e.format);
      },
      "reload": function () {
        app.tab.query.active(function (tab) {
          app.tab.reload(tab);
        });
      },
      "load": function () {
        app.tab.query.active(function (tab) {    
          if (tab) {
            if (tab.url) {
              const id = core.extract.id(tab.url);
              if (id) config.last.url = tab.url;
              /*  */
              core.action.process(id ? tab.url : config.last.url);
            }
          }
        });
      },
      "extract": function (e) {
        let id = '';
        /*  */
        if (e.url) {
          id = core.extract.id(e.url);
          if (id) {
            config.last.url = e.url;
          }
        } else {
          config.last.url = '';
        }
        /*  */
        app.popup.send("id", {"id": id ? id : "N/A"});
      }
    }
  }
};

app.popup.receive("load", core.action.popup.load);
app.popup.receive("reload", core.action.popup.reload);
app.popup.receive("extract", core.action.popup.extract);
app.popup.receive("download", core.action.popup.download);
app.popup.receive("support", function () {app.tab.open(app.homepage())});
app.popup.receive("donation", function () {app.tab.open(app.homepage() + "?reason=support")});

app.on.startup(core.start);
app.on.installed(core.install);
app.on.storage(core.action.storage);
