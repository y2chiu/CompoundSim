Calculate compound similarity 
=============================

##Requirements

Some tools or programs (ap, checkmol, obabel, simcomp, makekcf) should be pleased in prog/tools. 
Otherwise, need to modify the paths in the shell scripts.

##Steps

1. Prepare the compound MOL files

2. Generate compound features and KCF files
  ```
  sh prog/run_fea.sh example/NB2008/1_mol
  ```

3. Calculate compound similarity
  ```
  sh prog/run_comp.sh example/NB2008/ example/NB2008/ example_test
  ```

4. Result files
  - Merged file:  
    example_test_result.txt  
   
  - Feature compariosn:  
    example_test_fea_result.txt  
    example_test_fea_result.sorted.txt  
   
  - SIMCOMP comparison:   
    example_test_simcomp_result.txt  
    example_test_simcomp_result.sorted.txt  
