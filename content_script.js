'use strict';

// Make sure we are in strict mode.
(function() {
  var strictMode = false;
  try {
    NaN = NaN;
  } catch (err) {
    strictMode = true;
  }
  if (!strictMode) {
    throw 'Unable to activate strict mode.';
  }
})();

// Make sure the content script is only run once on the page.
if (!window.hashpassLoaded) {
  window.hashpassLoaded = true;

  var activeDoc = document;

  // Message handler.
  chrome.runtime.onMessage.addListener(
    function(request, sender, sendResponse) {
      // Trims the attribute and converts it to lowercase.
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

      // To make sure if the password field is selected or not
      if (request.type === 'checkForPass') {
        activeDoc = getactiveDoc();
        if (activeDoc && isPasswordInput(activeDoc.activeElement)) {
          sendResponse({ type: 'password' });
          return;
        }
        sendResponse({ type: 'not-password' });
        return;
      }

      // Automatically fill the password field if the enter key is selected
      if (request.type === 'fillPass') {
        if (isPasswordInput(activeDoc.activeElement)) {
          activeDoc.activeElement.value = request.hash;
          sendResponse({ type: 'close' });
          return;
        }
        sendResponse({ type: 'fail' });
        return;
      }
    }
  );
}
