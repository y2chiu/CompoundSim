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
  sh prog/run_fea.sh example/NB2011DRx/1_mol
  ```

3.1 Calculate compound similarity
  ```
  sh prog/run_comp.sh example/NB2008/ example/NB2011DRx/ example_test 0.5 0.5
  ```

  - Feature comparison only
  ```
  sh prog/compare_fea.sh example/NB2008/ example/NB2011DRx/ example_test 0.5 0.5
  ```

  - SIMCOMP comparison only
  ```
  sh prog/compare_simcomp.sh example/NB2008/ example/NB2011DRx/ example_test
  ```


3.2 Calculate compound similarity with PC-cluster
  ```
  sh prog/run_blade_comp.sh example/NB2008/ example/NB2011DRx/ example_test 0.5 0.5
  ```
  After finishing the script, submit jobs to PC-cluster
  ```
  sh towork.sh
  ```
  After finishing all jobs, merge the results
  ```
  sh tomerge.sh
  ```

4. Result files
  - Merged file:  
    example_test_result.txt  
   
  - Feature compariosn:  
    example_test_fea_result.txt 

  - SIMCOMP comparison:   
    example_test_simcomp_result.txt  
