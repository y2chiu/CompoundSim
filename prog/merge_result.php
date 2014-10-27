<?php
    ini_set('memory_limit',-1);

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
            $line = preg_split('/[\s]+/', $line);

            if(count($line) != 2)
                die(sprintf(" !! Not regular format: \n%s\n", join("!",$line)));

            list($k, $v) = $line;

            if(!isset($result[$k]))
                $result[$k] = array_fill(0, $argc-1,'-');

            $result[$k][$i] = $v;

            unset($k,$v,$line);
        }
    }

    foreach(array_keys($result) as $k)
    {
        if(!in_array('-', $result[$k]))
            printf("%s\t%s\n", $k, join("\t", $result[$k]));
    }

?>
