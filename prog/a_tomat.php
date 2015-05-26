<?
    ini_set('memory_limit','2048M');

    if($argc != 2)
    {
        die(sprintf("\nUsage: php %s [PAIR_FILE]\n\n", $argv[0]));
    }
        
    $fn = $argv[1];
    if(!file_exists($fn) || ($fp = fopen($fn,'r')) === false)
        die(sprintf(" !! Read file error ($fn).\n\n"));
       
    $mat    = array();
    $lst_k1 = array();
    $lst_k2 = array();

    while(!feof($fp))
    {
        $line = trim(fgets($fp));

        if(empty($line) || $line[0] == '#')
            continue;

        //list($k1, $k2, $sc) = explode("\t", $line);
        list($k1, $k2, $sc) = preg_split('/\s+/', $line);

        if(!isset($mat[$k1]))
            $mat[$k1] = array();
        
        $lst_k1[] = $k1;
        $lst_k2[] = $k2;
        $mat[$k1][$k2] = $sc;
    }

    $lst_k1 = array_unique($lst_k1);
    $lst_k2 = array_unique($lst_k2);
    sort($lst_k1);
    sort($lst_k2);

    $h = $lst_k2;
    echo "#\t", join("\t", $h), "\n";

    foreach($lst_k1 as $k1)
    {
        if(!isset($mat[$k1]))
        {
            fprintf(STDERR, " !! Missing key of %s, pass.\n", $k1);
            continue;
        }

        $o = array($k1);
        foreach($lst_k2 as $k2)
        {
            $v = 0;
            if(!isset($mat[$k1][$k2]))
            {
                fprintf(STDERR, " !! Missing values of %s-%s, set to 0.\n", $k1, $k2);
                $v = 0;
            }
            else
                $v = $mat[$k1][$k2];

            $o[] = $v;
        }

        echo join("\t", $o), "\n";
    }

?>
