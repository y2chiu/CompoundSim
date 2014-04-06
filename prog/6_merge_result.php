<?php
    ini_set('memory_limit','2048M');

    $result = array();

    array_shift($argv);
    foreach($argv as $i => $fn)
    {
        if(!file_exists($fn))
            die(sprintf(" !! No such file: %s\n", $fn));

        if(($fp = fopen($fn, 'r')) === NULL)
            die(sprintf(" !! Cannot open file: %s\n", $fn));

        while($line = fgets($fp))
        {
            $line = trim($line);
            $line = preg_split('/\s+/', $line);

            if(count($line) != 3)
                die(sprintf(" !! Not regular format: \n%s\n", join("!",$line)));

            list($a, $b, $v) = $line;

            if(!isset($result[$a]))
                $result[$a] = array();

            if(!isset($result[$a][$b]))
                $result[$a][$b] = array_fill(0, $argc-1,'-');
            
            $result[$a][$b][$i] = $v;

            unset($a,$b,$v,$line);
        }
    }

    foreach(array_keys($result) as $a)
    {
        foreach(array_keys($result[$a]) as $b)
            printf("%s\t%s\t%s\n", $a, $b, join("\t", $result[$a][$b]));
    }

?>
