// ad_blocker.js
(function () {
  var elements = document.querySelectorAll(
    'img[src*="://pagead2.googlesyndication.com/"], ' +
      'img[src*="://googleads.g.doubleclick.net/"], ' +
      'iframe[src*="://pagead2.googlesyndication.com/"], ' +
      'iframe[src*="://googleads.g.doubleclick.net/"]'
  );
  for (var i = 0; i < elements.length; i++) {
    elements[i].style.display = "none";
  }
})();
