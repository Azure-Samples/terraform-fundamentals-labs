var codeBlocks = document.querySelectorAll('pre.highlight');

codeBlocks.forEach(function (codeBlock) {
  var copyButton = document.createElement('button');
  copyButton.className = 'copy';
  copyButton.type = 'button';
  copyButton.ariaLabel = 'Copy code to clipboard';
  copyButton.innerText = 'Copy';

  var parentClasses = codeBlock.parentElement.parentElement.classList;
  var language = "";
  if(parentClasses.length == 2) {
    language = parentClasses[0].replace('language-', '');
  }

  var codeType = document.createElement('span');
  codeType.className = 'code-type';
  codeType.innerText = language;

  var codeDiv = document.createElement('div');
  codeDiv.className = 'code-div';
  codeDiv.appendChild(copyButton);
  codeDiv.appendChild(codeType);

  codeBlock.prepend(codeDiv);

  copyButton.addEventListener('click', function () {
    var code = codeBlock.querySelector('table.rouge-table td.rouge-code pre').innerText.trim();
    window.navigator.clipboard.writeText(code);

    copyButton.innerText = 'Copied';
    var fourSeconds = 4000;

    setTimeout(function () {
      copyButton.innerText = 'Copy';
    }, fourSeconds);
  });
});