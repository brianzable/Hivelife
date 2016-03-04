(function (document) {
  'use strict';

  var app = document.querySelector('#app');

  app.displayInstalledToast = function() {
    document.querySelector('#caching-complete').show();
  };

  app.updateSession = function () {
    if (app.session === null || typeof app.session === undefined) {
      app.authenticationToken = null;
    } else {
      app.authenticationToken = app.session.authentication_token;
    }

    app.$.sessionStore.value = app.session;
    app.$.rootManager.reloadMenu();
  };

  app.addEventListener('dom-change', function() {
    app.$.pages.addEventListener('page-redirect', function (event) {
      page.show(event.detail.path);
    });

    app.$.pages.addEventListener('app-message', function (event) {
      app.$.appToast.text = event.detail.message;
      app.$.appToast.show();
    });
  });
})(document);
