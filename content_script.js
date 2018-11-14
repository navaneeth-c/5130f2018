'use strict';

// To make sure we are in strict mode.
(function() {
  var sMode = false;
  try {
    NaN = NaN;
  } catch (err) {
    sMode = true;
  }
  if (!sMode) {
    throw 'Can not activate strict mode.';
  }
})();

// The content script should be execute
if (!window.hashpassLoaded) {
  window.hashpassLoaded = true;

  // Stores a document inside of which activeElement is located.
  var activeDoc = document;

  // Register the message handler.
  chrome.runtime.onMessage.addListener(
    function(request, sender, sendResponse) {
      // Convert the parameter to lowercase
      var toLower = function(attr) {
        return attr.replace(/^\s+|\s+$/g, '').toLowerCase();
      };

      // The function will check if the active element is present inside iframe
      var getactiveDoc = function() {
        var temp = document.activeElement;
        if (toLower(temp.tagName) === toLower('iframe')) {
          return temp.contentDocument;
        }
        return document;
      };

      // Checks whether the selected element is of type password or not
      var isPasswordInput = function(temp) {
        if (temp) {
          if (toLower(temp.tagName) === toLower('input')) {
            if (toLower(temp.type) === toLower('password')) {
              return true;
            }
          }
        }
        return false;
      };
    }
  );
}
