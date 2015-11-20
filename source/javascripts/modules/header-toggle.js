'use strict';

var $ = require('jquery');

exports.HeaderToggle = {
  el: '.header-menu-toggle',

  init: function() {
    this.cacheEls();
    this.bindEvents();

    this.$toggle.text('Menu');
  },

  bindEvents: function() {
    this.$toggle.on('click', this.toggle);
  },

  cacheEls: function() {
    this.$toggle = $(this.el);
  },

  toggle: function (e) {
    var $el = $(e.target)
    var $target = $($el.attr('href'));

    e.preventDefault();

    $el.toggleClass('js-hidden');
    $target.toggleClass('js-visible');
  }
};
