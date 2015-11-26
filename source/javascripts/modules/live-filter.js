'use strict';

var angular = require('angular');
var $ = require('jquery');
var each = require('lodash/collection/each');
var map = require('lodash/collection/map');
var filter = require('lodash/collection/filter');
var flatten = require('lodash/array/flatten');

exports.LiveFilter = {
  init: function() {
    var app = angular.module('ukti', []);

    app.factory('countriesFactory', countriesFactory);

    app.controller('LiveFilterCtrl', LiveFilterController);

    app.directive('countries', countriesDirective);

    app.filter('cleanUrl', cleanUrl);

    angular.bootstrap(document.body, ['ukti']);
  },

};

/////////////////////////////

function countriesFactory ($http) {
  return function() {
    return $http({
      url: window.BASE_PATH + 'countries_by_letter.json'
    });
  };
}

function LiveFilterController ($scope, countriesFactory) {
  countriesFactory().then(function(res) {
    var countries = res.data;

    $scope.countries = countries;

    $scope.getCount = function () {
      var countries = map($scope.countries, function (v, k) {
        return v;
      });
      return flatten(countries).length;
    };

    $scope.filter = function (query) {
      var filtered = {};
      query = query.toLowerCase() || '';

      each(countries, function (v, k) {
        v = filter(v, function (c) {
          return ~c.toLowerCase().indexOf(query);
        });

        filtered[k] = v;
      });

      $scope.countries = filtered;
    };
  });
}

function countriesDirective (countriesFactory) {
  return {
    restrict: 'E',
    replace: true,
    scope: {
      countries: '=data'
    },
    templateUrl: window.BASE_PATH + 'partials/countries.html'
  };
}

function cleanUrl () {
  return function (input) {
    return input
            .toLowerCase()
            .replace(/\s/g, '-')
            .replace(/[^a-z0-9-]/ig,'');
  };
}
