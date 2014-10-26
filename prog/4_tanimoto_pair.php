<?php
    ini_set('memory_limit', '2048M');


    if($argc != 4)
        die(sprintf(" Usage: %s QUERY_FEA SEARCH_FEA THRESHOLD\n\n", $argv[0]));
    
    $TH = doubleval($argv[3]);
    $TH = ($TH > 1) ? 1 : $TH;
    $TH = ($TH < 0) ? 0 : $TH;

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

    //sort($kq, SORT_STRING);
    //sort($ks, SORT_STRING);
    //$ns = count($ks);
    foreach($kq as $qi=>$q)
    {
            //$qn = array_reverse(explode('-',$q,2));
            //$qn = array($q);
            $qn = $q;
            
        foreach($ks as $si=>$s)
        {
            //$sn = array_reverse(explode('-',$s,2));
            //$sn = array($s);
            $sn = $s;

            $idx  = $si + 1;

            $vand = $qfa[$q]&$sfa[$s];
            $vor  = $qfa[$q]|$sfa[$s];

            $vand = count_chars($vand);
            $vor  = count_chars($vor );

            $vand = $vand[49]; // 1
            $vor  = $vor[49];

            $tani = ($vor) ? round(doubleval($vand)/$vor,2) : 0;

            //$o = array_merge( $qn, $sn, array($tani));
            
            if($tani >= $TH) 
            {
                //$o = array($qn.'_'.$idx, $qn, $sn, $tani);
                //echo join("\t", $o), "\n";
                printf("%s|%s\t%s\n", $qn, $sn, $tani);
            }
        }

        unset($out, $v, $q, $max);
    }

?>
