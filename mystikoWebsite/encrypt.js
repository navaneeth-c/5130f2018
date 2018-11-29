var update = function() {
  // Compute the first 16 base64 characters of iterated-SHA-256(domain + '/' + key, 2 ^ roundsDifficulty).
  // var key = $('#key').val();
  // domain = $('#domain').val().replace(/^\s+|\s+$/g, '').toLowerCase();
  //
  // var permutations = Math.pow(2, roundsDifficulty);
  // var bits = domain + '/' + key;
  // for (var i = 0; i < permutations; i += 1) {
  //   bits = sjcl.hash.sha256.hash(bits);
  // }
  //
  // var hash = sjcl.codec.base64.fromBits(bits).slice(0, 16);
  // if (!passMode) {
  //   $('#hash').val(hash);
  // }
  // return hash;

  var domain = document.getElementById("domain").value
  console.log($domain);
  alert($domain);
};
