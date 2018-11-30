var update = function() {
  // Compute the first 16 base64 characters of iterated-SHA-256(domain + '/' + key, 2 ^ roundsDifficulty).
  var key = document.getElementById("key").value;
  domain = document.getElementById("domain").value.replace(/^\s+|\s+$/g, '').toLowerCase();
  var roundsDifficulty = 16;
  var permutations = Math.pow(2, roundsDifficulty);
  var bits = domain + '/' + key;
  console.log(bits);
  for (var i = 0; i < permutations; i += 1) {
    bits = sjcl.hash.sha256.hash(bits);
  }
  var hash = sjcl.codec.base64.fromBits(bits).slice(0, 16);
  console.log(hash);
  window.alert("Your password is copied to the clipboard");
  const el = document.createElement('textarea');
  el.value = hash;
  document.body.appendChild(el);
  el.select();
  document.execCommand('copy');
  document.body.removeChild(el);
};
