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

    app.$.pages.addEventListener('page-redirect', function (event) {
      page.show(event.detail.path);
    });

    app.$.pages.addEventListener('app-message', function (event) {
      app.$.appToast.text = event.detail.message;
      app.$.appToast.show();
    });
  });
})(document);
