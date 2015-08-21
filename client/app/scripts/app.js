(function (document) {
  'use strict';

  // Grab a reference to our auto-binding template
  // and give it some initial binding values
  // Learn more about auto-binding templates at http://goo.gl/Dx1u2g
  var app = document.querySelector('#app');

  app.displayInstalledToast = function() {
    document.querySelector('#caching-complete').show();
  };

  app.addEventListener('dom-change', function() {
    app.$.sessionStore.addEventListener('value-changed', function (event) {
      var session = event.detail.value;
      if (session === null) {
        app.authenticationToken = null;
      } else {
        app.authenticationToken = session.authentication_token;
      }

      app.$.rootManager.reloadMenu();
    });

    app.$.rootManager.addEventListener('page-redirect', function (event) {
      page.redirect(event.detail.path);
    });
  });

  // See https://github.com/Polymer/polymer/issues/1381
  window.addEventListener('WebComponentsReady', function() {

  });
})(document);
