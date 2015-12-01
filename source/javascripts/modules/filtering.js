'use strict';

var angular = require('angular');
var $ = require('jquery');
var each = require('lodash/collection/each');
var filter = require('lodash/collection/filter');
var map = require('lodash/collection/map');
var includes = require('lodash/collection/includes');

exports.Filtering = {
  el: '.ng-filtering',

  init: function() {
    var app = angular.module('filtering', []);

    app.factory('searchDataFactory', searchDataFactory);

    app.controller('FilteringCtrl', FilteringCtrl);

    app.filter('capitalize', capitalize);
    app.filter('multiFilter', multiFilter);
    app.filter('cleanUrl', cleanUrl);
    app.filter('dateFormat', dateFormat);

    angular.bootstrap($(this.el), ['filtering']);
  },

};

/////////////////////////////

function searchDataFactory ($http, $window) {
  return function(type) {
    return $http({
      url: $window.BASE_PATH + 'data/' + type + '.json'
    });
  };
}

function FilteringCtrl ($scope, $window, searchDataFactory) {
  $scope.loading = true;
  $scope.formData = {};

  // set from query string
  var params = getQueryParameters();
  each(params, function (v, param) {
    var values = v.split(',');
    $scope.formData[param] = $scope.formData[param] || {};

    each(values, function (value) {
      $scope.formData[param][decodeURIComponent(value)] = true;
    });
  });

  searchDataFactory($window.SEARCH_DATA).then(function(res) {
    $scope.results = res.data;
    $scope.loading = false;
  });

  $scope.checkedCount = function (model) {
    return filter(model, function(item){
      return item;
    }).length;
  };

  $scope.selectedOptions = getSelectedOptions;

  // update url with filter changes
  $scope.$watch('formData', function (newVal, oldVal) {
    if (newVal === oldVal) {
      return;
    }

    var query = {};
    each(newVal, function (values, key) {
      var filteredValues = getSelectedOptions(values);

      filteredValues = map(filteredValues, function (value) {
        return encodeURIComponent(value);
      });

      if (filteredValues.length) {
        query[key] = filteredValues.join();
      }
    });

    var queryStr = map(query, function (v, k) {
      return k + "=" + v;
    }).join("&");

    window.history.pushState(null, null, '?' + queryStr);
  }, true);
}

function getSelectedOptions (filter) {
  var options = [];

  if (filter) {
    each(filter, function (v, k) {
      if (v) {
        options.push(k);
      }
    });
  }
  
  return options;
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

function cleanUrl () {
  return function (input) {
    return input
            .toLowerCase()
            .replace(/\s/g, '-')
            .replace(/[^a-z0-9-]/ig,'');
  };
}

function dateFormat ($filter) {
  return function (input) {
    if (!isDate(input)) {
      return input;
    }

    return $filter('date')(Date.parse(input), 'd MMMM yyyy');
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

        if(itemProperties[key] && filteredValues.length > 0 && !includes(filteredValues, itemProperties[key].toLowerCase())) {
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

function getQueryParameters () {
  var search = location.search.substring(1);

  if (!search) {
    return {};
  }

  return JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g,'":"') + '"}', function(key, value) {
    return key === '' ? value : decodeURIComponent(value);
  });
}

function isDate (date) {
  return ( (new Date(date) !== "Invalid Date" && !isNaN(new Date(date)) ));
}
