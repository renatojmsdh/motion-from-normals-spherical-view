 # Code of "An Efficient Rotation and Translation Decoupled Initialization from Large Field of View Depth Images" 
 ## Renato Martins, Eduardo Fernandez-Moral, Patrick Rives
 ## Email: renatojmsdh@gmail.com
 ## INRIA Sophia Antipolis, 2018
  
  ## DOC:
  * Please see the documentation and dependencies of this module in the "doc/" folder, by opening the index.html in your brownser
   
  ## Running instructions:
  * Open Matlab and select your current working directory as the one with the "main.m" function, open this function and run it. 
  * The salience function uses a compiled mex file for selecting the most informative information for the translation estimation. The code was compiled in Ubuntu 16.04 
  and should run in a similar PC architecture. If not, please compile the file "mex_saliency_geometry.cpp".
  
  ## Short description:

   This is an example for computing the pose initialization
   from normals using wide FOV sensors as in the IROS 2017 Paper:
   * An Efficient Rotation and Translation Decoupled Initialization from Large Field of View Depth Images
     R Martins, E Fernandez-Moral, P Rives 
     IEEE/RSJ International Conference on Intelligent Robots and Systems, IROS'17 

  If this code is useful for you, please cite our paper in your research as:
  ```
   @inproceedings{martins17,
    author    = {Renato Martins and
               Eduardo Fernandez{-}Moral and
               Patrick Rives},
    title     = {An efficient rotation and translation decoupled initialization from
               large field of view depth images},
    booktitle = {{IEEE/RSJ} International Conference on Intelligent Robots and
               Systems, {IROS}, Vancouver, Canada},    
    year      = {2017}
    } 
