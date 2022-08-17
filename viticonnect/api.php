<?php 

include("config.php");

$login = $_GET['login'];
$epoch = $_GET['epoch'];
$md5 = $_GET['md5'];

if(abs(time() - $epoch) > 30) {
    http_response_code(403);
    die('Forbidden');
}
if ($md5 != md5($api_secret."/".$login."/".$epoch)) {
    http_response_code(401);
    die("Unauthorized");
}

$con = ldap_connect($ldap_host);
ldap_set_option($con, LDAP_OPT_PROTOCOL_VERSION, 3);
ldap_bind($con);
$search = ldap_search($con, $ldap_basedn, 'uid='.$login);
$info = ldap_get_entries($con, $search);
header("Content-Type: text/plain\n");
if (!isset($info['count']) || !($info['count']) ):
?>
<cas:viticonnect_entities>
<cas:viticonnect_entities_number>0</cas:viticonnect_entities_number>
</cas:viticonnect_entities>
<?php
exit; 
endif; ?>
<cas:viticonnect_entities>
<cas:viticonnect_entities_number>1</cas:viticonnect_entities_number>
<?php if (isset($viticonnect2ldap['raison_sociale']) && isset($info[0][$viticonnect2ldap['raison_sociale']]) && $info[0][$viticonnect2ldap['raison_sociale']][0]): ?>
<cas:viticonnect_entity_1_raison_sociale><?php echo $info[0][$viticonnect2ldap['raison_sociale']][0] ?></cas:viticonnect_entity_1_raison_sociale>
<cas:viticonnect_entity_all_raison_sociale><?php echo $info[0][$viticonnect2ldap['raison_sociale']][0] ?></cas:viticonnect_entity_all_raison_sociale>
<?php endif; ?>
<?php if (isset($viticonnect2ldap['cvi']) && isset($info[0][$viticonnect2ldap['cvi']]) && $info[0][$viticonnect2ldap['cvi']][0]): ?>
<cas:viticonnect_entity_all_cvi><?php echo $info[0][$viticonnect2ldap['cvi']][0] ?></cas:viticonnect_entity_all_cvi>
<cas:viticonnect_entity_1_cvi><?php echo $info[0][$viticonnect2ldap['cvi']][0] ?></cas:viticonnect_entity_1_cvi>
<?php endif; ?>
<?php if (isset($viticonnect2ldap['siret']) && isset($info[0][$viticonnect2ldap['siret']]) && $info[0][$viticonnect2ldap['siret']][0]): ?>
<cas:viticonnect_entity_all_siret><?php echo $info[0][$viticonnect2ldap['siret'[0]]] ?></cas:viticonnect_entity_all_siret>
<cas:viticonnect_entity_1_siret><?php echo $info[0][$viticonnect2ldap['siret'[0]]] ?></cas:viticonnect_entity_1_siret>
<?php endif; ?>
<?php if (isset($viticonnect2ldap['accises']) && isset($info[0][$viticonnect2ldap['accises']]) && $info[0][$viticonnect2ldap['accises']][0]): ?>
<cas:viticonnect_entity_all_accises><?php echo $info[0][$viticonnect2ldap['accises']][0] ?></cas:viticonnect_entity_all_accises>
<cas:viticonnect_entity_1_accises><?php echo $info[0][$viticonnect2ldap['accises']][0] ?></cas:viticonnect_entity_1_accises>
<?php endif; ?>
<?php if (isset($viticonnect2ldap['tva']) && isset($info[0][$viticonnect2ldap['tva']]) && $info[0][$viticonnect2ldap['tva']][0]): ?>
<cas:viticonnect_entity_all_tva><?php echo $info[0][$viticonnect2ldap['tva']][0] ?></cas:viticonnect_entity_all_tva>
<cas:viticonnect_entity_1_tva><?php echo $info[0][$viticonnect2ldap['tva']][0] ?></cas:viticonnect_entity_1_tva>
<?php endif; ?>
<?php if (isset($viticonnect2ldap['ppm']) && isset($info[0][$viticonnect2ldap['ppm']]) && $info[0][$viticonnect2ldap['ppm']][0]): ?>
<cas:viticonnect_entity_all_ppm><?php echo $info[0][$viticonnect2ldap['ppm']][0] ?></cas:viticonnect_entity_all_ppm>
<cas:viticonnect_entity_1_ppm><?php echo $info[0][$viticonnect2ldap['ppm']][0] ?></cas:viticonnect_entity_1_ppm>
<?php endif; ?>
</cas:viticonnect_entities>

