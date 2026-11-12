<?php
/* =========================================================
   submit.php — target of the "Form Demo" on the landing page (index.html)
   The demo form never saves anything on the public site. It sends the visitor
   to the login (a logged-in user is forwarded from there to the dashboard).
   config.php is NOT loaded on purpose: the static page has no CSRF token.
   ========================================================= */
header('Location: login.php', true, 303);
exit;
