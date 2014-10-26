<?
    if($argc != 5)
        die(sprintf("%s: Wrong argv\n", $argv[0]));

    $scmd = $argv[1];
    $type = $argv[2];
    $kcf1 = $argv[3];
    $kcf2 = $argv[4];


    $lst2 = array();
    $ln   = '';
    
    $fp = fopen($kcf2,'r');
    while(($ln = fgets($fp)))
    {
        $lst2[] = trim($ln);
    }
    fclose($fp);

    $num  = count($lst2);

    $fp = fopen($kcf1,'r');
    while(($ln = fgets($fp)))
    {
        $ln = trim($ln);
        for($i=0;$i<$num;$i++)
            printf("%s -m k_to_k --%s %s %s\n", $scmd, $type, $ln, $lst2[$i]);
    }
    fclose($fp);

?>
