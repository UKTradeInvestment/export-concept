'use strict';

var angular = require('angular');
var $ = require('jquery');
var each = require('lodash/collection/each');
var filter = require('lodash/collection/filter');
var includes = require('lodash/collection/includes');

exports.Filtering = {
  el: '.ng-filtering',

  init: function() {
    var app = angular.module('filtering', []);

    app.factory('opportunitiesFactory', opportunitiesFactory);

    app.controller('FilteringCtrl', FilteringCtrl);

    app.filter('capitalize', capitalize);
    app.filter('multiFilter', multiFilter);

    angular.bootstrap($(this.el), ['filtering']);
  },

};

/////////////////////////////

function opportunitiesFactory ($http) {
  return function() {
    return $http({
      url: window.BASE_PATH + 'data/opportunities.json'
    });
  };
}

function FilteringCtrl ($scope, opportunitiesFactory) {
  $scope.loading = true;

  opportunitiesFactory().then(function(res) {
    $scope.opportunities = res.data;
    $scope.loading = false;
  });

  $scope.checkedCount = function (model) {
    return filter(model, function(item){
      return item;
    }).length;
  };

  $scope.selectedOptions = function (filter) {
    var options = [];

    if (filter) {
      each(filter, function (v, k) {
        if (v) {
          options.push(k);
        }
      });
    }
    
    return options;
  };
}

function capitalize () {
  return function (input) {
    if (input !== null) {
      input = input
                .toLowerCase()
                .replace(/[_]/ig,' ');

      return input.substring(0, 1).toUpperCase() + input.substring(1);
    }
  };
}

function multiFilter () {
  return function (items, filters) {
    var filtered = [];

    each(items, function (item) {
      var itemProperties = item.meta;
      var include = true;

      each(filters, function (values, key) {
        var props = filter(itemProperties, { 'name': key });
        var filteredValues = [];

        each(values, function (v, k) {
          if (v) {
            filteredValues.push(k.toLowerCase());
          }
        });

        if(filteredValues.length > 0 && !includes(filteredValues, itemProperties[key].toLowerCase())) {
          include = false;
        }
      });

      if (include) {
        filtered.push(item);
      }
    });

    return filtered;
  };
}
