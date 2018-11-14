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
// 2 ^ roundsDifficulty rounds of SHA-256 will be computed.
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

      // to check whether we got the right tab
      if (tabs.length !== 1) {
        return printError('Can not find the active tab');
      }

      // find the domain url
      var domain-url = null;
      var matches = tabs[0].url.match(/^http(?:s?):\/\/([^/]*)/);
      if (matches) {
        domain-url = matches[1].toLowerCase();
      } else {
        return printError('Unable to find the domain url');
      }
      if (/^http(?:s?):\/\/chrome\.google\.com\/webstore.*/.test(tabs[0].url)) {
        // Technical reason: Chrome prevents content scripts from running in the app gallery.
        return printError('This extension will not work on google chrome');
      }
      $('#domain-url').val(domain-url);

      // have to design the content_script. It is planned for the next submission
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

            // This function will be called whenever the master key changes.
            var update = function() {
              // Compute the encryption of the password using a hasing function. Yet to determine the hashing function
              //Incomplete
            };

            if (passMode) {
              // This peace of code looks for the ENTER key
              $('#domain-url, #masterKey').masterKeydown(function(e) {
                if (e.which === 13) {
                  // Try to fill the selected password field with the hashedPassword.
                  chrome.tabs.sendMessage(tabs[0].id, {
                      type: 'hashedPasswordpassFillPasswordField',
                      hashedPassword: update()
                    }, function(response) {
                      // If successful, close the popup.
                      if (response.type === 'close') {
                        window.close();
                      }
                    }
                  );
                }
              });
            }
            $('#masterKey').focus();
          }
        );
      });
    }
  );
});
