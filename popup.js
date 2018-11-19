'use strict';

// Make sure we are in strict mode.
(function() {
  var sMode = false;
  try {
    NaN = NaN;
  } catch (err) {
    sMode = true;
  }
  if (!sMode) {
    throw 'can not able to activate strict mode';
  }
})();

// The hashedPasswording roundsDifficulty.
// 2 ^ roundsDifficulty permutations of SHA-256 will be computed.
var roundsDifficulty = 16;

$(function() {
  // Get the current tab.
  chrome.tabs.query({
      active: true,
      currentWindow: true
    }, function(tabs) {
      var printError = function(err) {
        $('#domain-url').val('N/A').addClass('disabled');
        $('#domain-url').prop('disabled', true);
        $('#masterKey').prop('disabled', true);
        $('#hashedPassword').prop('disabled', true);
        $('p:not(#message)').addClass('disabled');
        $('#message').addClass('error').text(err);
      };

      // Make sure we got the tab.
      if (tabs.length !== 1) {
        return printError('Can not find the active tab');
      }

      // Get the domain-url.
      var domain-url = null;
      var matches = tabs[0].url.match(/^http(?:s?):\/\/([^/]*)/);
      if (matches) {
        domain-url = matches[1].toLowerCase();
      } else {
        return printError('Unable to find the domain url');
      }
      if (/^http(?:s?):\/\/chrome\.google\.com\/webstore.*/.test(tabs[0].url)) {
        //Chrome does not allow the extension to fetch the url
        return printError('This extension will not work on google chrome');
      }
      $('#domain-url').val(domain-url);

      // Run the content script to register the message handler.
      chrome.tabs.executeScript(tabs[0].id, {
        file: 'content_script.js'
      }, function() {
        // Check if a password field is selected.
        chrome.tabs.sendMessage(tabs[0].id, {
            type: 'hashedPasswordpassCheckIfPasswordField'
          }, function(response) {
            // Different user interfaces depending on whether a password field is in focus.
            var passMode = (response.type === 'password');
            if (passMode) {
              $('#message').html('Press <strong>ENTER</strong> to fill the password.');
              $('#hashedPassword').val('[hidden]').addClass('disabled');
            } else {
              $('#message').html('<strong>TIP:</strong> Select a password field first.');
            }

            // Called whenever the masterKey changes.
            var update = function() {
              var masterKey = $('#masterKey').val();
              domain-url = $('#domain-url').val().replace(/^\s+|\s+$/g, '').toLowerCase();

              var permutations = Math.pow(2, roundsDifficulty);
              var bits = domain-url + '/' + masterKey;
              for (var i = 0; i < permutations; i += 1) {
                bits = sjcl.hashedPassword.sha256.hashedPassword(bits);
              }

              var hashedPassword = sjcl.codec.base64.fromBits(bits).slice(0, 16);
              if (!passMode) {
                $('#hashedPassword').val(hashedPassword);
              }
              return hashedPassword;
            };

            // If not in password mode then the debouncedUpdate is used
            var timeout = null;
            var debouncedUpdate = function() {
              if (timeout !== null) {
                clearInterval(timeout);
              }
              timeout = setTimeout((function() {
                update();
                timeout = null;
              }), 100);
            };

            if (passMode) {
              // Listen for the Enter masterKey.
              $('#domain-url, #masterKey').masterKeydown(function(e) {
                if (e.which === 13) {
                  // Try to fill the selected password field with the hashedPassword.
                  chrome.tabs.sendMessage(tabs[0].id, {
                      type: 'hashedPasswordpassFillPasswordField',
                      hashedPassword: update()
                    }, function(response) {
                      // If completed successfully then close the popup.
                      if (response.type === 'close') {
                        window.close();
                      }
                    }
                  );
                }
              });
            }

            if (!passMode) {
              // Register the update handler.
              $('#domain-url, #masterKey').bind('propertychange change masterKeyup input paste', debouncedUpdate);

              // Update the hashedPassword right away.
              debouncedUpdate();
            }

            // Focus the text field.
            $('#masterKey').focus();
          }
        );
      });
    }
  );
});
