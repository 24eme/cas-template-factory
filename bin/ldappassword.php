<?php

$pass = rtrim(fgets(STDIN));
mt_srand((double) microtime() * 1000000);
$salt = pack("CCCC", mt_rand(), mt_rand(), mt_rand(), mt_rand());
echo "{SSHA}" . base64_encode(pack("H*", sha1($pass . $salt)) . $salt)."\n";
