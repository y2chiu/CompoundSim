<?php
    ini_set('memory_limit', '1024M');


    if($argc!=3)
        die(sprintf(" Usage: %s QUERY_FEA SEARCH_FEA\n\n", $argv[0]));

    // query    
    $qfn = $argv[1];
    $qfa = array();

    if(!file_exists($qfn) || ($fin = fopen($qfn,'r')) === false)
        die(sprintf(" !! Read file error ($qfn).\n\n"));

    while($line = fgets($fin)) 
    {
        if($line[0] == '#')    continue;

        $a = preg_split('/\s+/',trim($line),2);
        $m = array_shift($a);

        if(array_key_exists($m, $qfa))
            fprintf(STDERR, " !! Error, repeat molecule in QUERY (%s).\n", $m);

        $qfa[$m] = end($a);

        unset($line, $a);
    }
    fclose($fin);


    // search
    $sfn = $argv[2];
    $sfa = array();

    if(!file_exists($sfn) || ($fin = fopen($sfn,'r')) === false)
        die(sprintf(" !! Read file error ($sfn).\n\n"));

    while($line = fgets($fin)) 
    {
        if($line[0] == '#')    continue;

        $a = preg_split('/\s+/',trim($line),2);
        $m = array_shift($a);

        if(array_key_exists($m, $sfa))
            fprintf(STDERR, " !! Error, repeat molecule in SEARCH (%s).\n", $m);

        $sfa[$m] = end($a);

        unset($line, $a);
    }
    fclose($fin);




    $kq = array_keys($qfa);
    $ks = array_keys($sfa);

    //$header = array('#Query', 'BestSim', 'Tani', '|');
    //$header = array_merge($header, $ks);

    //echo join("\t", $header), "\n";

    foreach($kq as $q)
    {
        //$max = array('-', 0);
        //$v = array();
            $qn = array_reverse(explode('-',$q,2));
            $qn = array($q);

        foreach($ks as $s)
        {
            //if($q == $s)    continue;

            $sn = array_reverse(explode('-',$s,2));
            $sn = array($s);

            $vand = $qfa[$q]&$sfa[$s];
            $vor  = $qfa[$q]|$sfa[$s];

            $vand = count_chars($vand);
            $vor  = count_chars($vor );

            $vand = $vand[49]; // 1
            $vor  = $vor[49];

            $tani = ($vor) ? round(doubleval($vand)/$vor,2) : 0;
            //$v[] = $tani;

            //if($tani > $max[1]) 
            //    $max = array($s, $tani);

            $o = array_merge( $qn, $sn, array($tani));
            echo join("\t", $o), "\n";
        }

        //$out = sprintf("%%s\t%%s\t%%.2f\t|\t%s\n", str_repeat("%.2f\t", count($v)-1));
        //array_unshift($v, $q, $max[0], $max[1]);
        //vprintf($out, $v);

        unset($out, $v, $q, $max);
    }

?>
