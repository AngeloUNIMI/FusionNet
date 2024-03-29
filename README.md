# FusionNet

Matlab source code for the paper:

	A. Genovese, V. Piuri, F. Scotti, and S. Vishwakarma, 
	"Touchless palmprint and finger texture recognition: A Deep Learning fusion approach", 
	in Proc. of the 2019 IEEE Int. Conf. on Computational Intelligence & Virtual Environments for Measurement Systems and Applications (CIVEMSA 2019), 
	Tianjin, China, June 14-16, 2019, pp. 1-6. 
	ISBN: 978-1-5386-8344-6. DOI: 10.1109/CIVEMSA45640.2019.9071620
	
Paper:

https://ieeexplore.ieee.org/document/9071620
	
Project page:

[http://iebil.di.unimi.it/fusionnet/index.htm](http://iebil.di.unimi.it/fusionnet/index.htm)
    
Outline:
![Outline](https://iebil.di.unimi.it/palmnet/imgs/outline_fusionnet.png "Outline")

Demo:

[https://github.com/AngeloUNIMI/Demo_FusionNet](https://github.com/AngeloUNIMI/Demo_FusionNet)

Citation:

	@InProceedings {civemsa19,
	    author = {A. Genovese and V. Piuri and F. Scotti and S. Vishwakarma},
	    booktitle = {Proc. of the 2019 IEEE Int. Conf. on Computational Intelligence & Virtual Environments
	    for Measurement Systems and Applications (CIVEMSA 2019)},
	    title = {Touchless palmprint and finger texture recognition: A Deep Learning fusion approach},
	    address = {Tianjin, China},
	    month = {June},
	    day = {14-16},
	    year = {2019},
	    pages = {1-6},
	}

Main files:

- main_FusionNet.m: main file

Required files:

- ./images/DB Fusion Palm-Knuckle (orig)/REST_hand_database: <br/>
Database of images downloaded from: http://www.regim.org/publications/databases/regim-sfax-tunisian-hand-database2016-rest2016/<br/>
The structure of the folders must be:<br/>
"images/DB Fusion Palm-Knuckle (orig)/REST_hand_database/p1"<br/>
"images/DB Fusion Palm-Knuckle (orig)/REST_hand_database/p2"<br/>
etc.

Part of the code uses the Matlab source code of the paper:

- T. Chan, K. Jia, S. Gao, J. Lu, Z. Zeng and Y. Ma, 
"PCANet: A Simple Deep Learning Baseline for Image Classification?," 
in IEEE Transactions on Image Processing, vol. 24, no. 12, pp. 5017-5032, Dec. 2015.
DOI: 10.1109/TIP.2015.2475625
[http://mx.nthu.edu.tw/~tsunghan/Source%20codes.html](http://mx.nthu.edu.tw/~tsunghan/Source%20codes.html)
	
the VLFeat library:

- A. Vedaldi and B. Fulkerson, 
"VLFeat: An Open and Portable Library of Computer Vision Algorithms", 2008, 
[http://www.vlfeat.org](http://www.vlfeat.org/)
	
and the functions by Peter Kovesi:

- Peter Kovesi, 
"MATLAB and Octave Functions for Computer Vision and Image Processing", 
[https://www.peterkovesi.com/matlabfns](https://www.peterkovesi.com/matlabfns/)
	
The database used in the paper can be obtained at:

- REST:<br/>
[http://www.regim.org/publications/databases/regim-sfax-tunisian-hand-database2016-rest2016](http://www.regim.org/publications/databases/regim-sfax-tunisian-hand-database2016-rest2016/)

	
