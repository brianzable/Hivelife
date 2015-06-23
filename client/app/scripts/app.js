(function (document) {
  'use strict';

  // Grab a reference to our auto-binding template
  // and give it some initial binding values
  // Learn more about auto-binding templates at http://goo.gl/Dx1u2g
  var app = document.querySelector('#app');

  var loggedInMenuOptions = [
    { route: 'users',    path: '/users',    icon: 'info', text: 'Users' },
    { route: 'apiaries', path: '/apiaries/1', icon: 'mail', text: 'Apiaries' },
    { route: 'logout',   path: '/logout',   icon: 'mail', text: 'Logout' },
  ];

  var loggedOutMenuOptions = [
    { route: 'home',    path: '/',      icon: 'home', text: 'Home' },
    { route: 'login',   path: '/login', icon: 'home', text: 'Login' }
  ];

  app.showLoggedInMenu = function () {
    app.menuOptions = loggedInMenuOptions;
  };

  app.showLoggedOutMenu = function () {
    app.menuOptions = loggedOutMenuOptions;
  };

  app.displayInstalledToast = function() {
    document.querySelector('#caching-complete').show();
  };

  app.clearSession = function () {
    this.showLoggedOutMenu();
    this.authenticationToken = null;
    window.localStorage.removeItem('authenticationToken');
  };

  app.userLoggedIn = function () {
    return this.authenticationToken !== null;
  };

  app.addEventListener('dom-change', function() {
    console.log('Our app is ready to rock!');
  });

  document.addEventListener('page-redirect', function (event) {
    page.redirect(event.detail.path);
  });

  document.addEventListener('session-create', function (event) {
    var authenticationToken = event.detail.authenticationToken;
    app.authenticationToken = authenticationToken;
  });

  document.addEventListener('user-unauthorized', function () {
    this.clearSession();
    page.redirect('/login');
  });

  // See https://github.com/Polymer/polymer/issues/1381
  window.addEventListener('WebComponentsReady', function() {
    // imports are loaded and elements have been registered
  });

  // Close drawer after menu item is selected if drawerPanel is narrow
  app.onMenuSelect = function() {
    var drawerPanel = document.querySelector('#paperDrawerPanel');
    if (drawerPanel.narrow) {
      drawerPanel.closeDrawer();
    }
  };

  app.authenticationToken = window.localStorage.getItem('authenticationToken');
  app.menuOptions = app.userLoggedIn() ? loggedInMenuOptions : loggedOutMenuOptions;

})(document);
