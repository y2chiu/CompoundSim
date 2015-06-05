<?

    $fn  = $argv[1];
    #$set = ($argc >2) ? $argv[2].'-' : '';

    if(!file_exists($fn) || ($fin = fopen($fn,'r')) === false)
    {
        fprintf(STDERR, " !! Read file error ($fn).\n\n");
        exit;
    }


    while($line = fgets($fin)) 
    {
        $t = trim($line);
        if(empty($t) || $t[0] == '#')    
            continue;

        $t = explode("\t", $t);

        //$c = $t[2];
        //array_splice($t,0,4);
        $c = basename($t[0], '.mol');
        $c = basename($t[0], '.mol2');

        $fea = array();
        foreach($t as $v)
            $fea[] = ($v!=0) ? 1 : 0;
        $fea = join('',$fea);

        #printf("%s%s\t%s\n", $set, $c, $fea);
        printf("%s\t%s\n", $c, $fea);

        unset($t,$line);
    }

    fclose($fin);
?>
