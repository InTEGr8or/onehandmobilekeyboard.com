(function () {
  var form = document.getElementById("list-form");
  if (!form) return;
  var input = document.getElementById("list-email");
  var status = document.getElementById("list-status");
  // A usable address has a local part, an @, and a domain with a lettered
  // ending. Phone numbers and bare words fail this. It does not prove the
  // mailbox exists.
  var emailShape = /^[a-zA-Z0-9](?:[a-zA-Z0-9._%+-]{0,62}[a-zA-Z0-9])?@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z]{2,24})+$/;
  var phoneShape = /^\+?[\d\s().-]{7,}$/;

  function verdict(value) {
    var text = value.trim();
    if (!text) return "Enter an email address.";
    if (phoneShape.test(text) || /^\d{6,}$/.test(text.replace(/\D/g, "")) && text.indexOf("@") === -1) {
      return "That looks like a phone number, not an email address.";
    }
    if (text.indexOf(" ") !== -1 || text.indexOf("..") !== -1 || !emailShape.test(text)) {
      return "That does not look like an email address.";
    }
    return "";
  }

  form.addEventListener("submit", function (event) {
    event.preventDefault();
    var problem = verdict(input.value);
    if (problem) {
      status.textContent = problem;
      input.setAttribute("aria-invalid", "true");
      input.focus();
      return;
    }
    input.removeAttribute("aria-invalid");
    status.textContent = "That address has the right shape. This page does not store it yet, so nothing was added.";
  });
})();
