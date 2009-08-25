<?php
// Date in the past
header("Cache-Control: no-cache");
header("Pragma: no-cache");

readfile("main_index.html");
?>
