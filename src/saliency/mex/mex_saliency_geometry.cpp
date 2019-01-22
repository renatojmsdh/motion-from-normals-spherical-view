#include <mex.h>
#include <matrix.h>
#include <math.h>

#include <iostream>

using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray  *prhs[] )
{


   if((nrhs<2)||(nlhs<1)) mexErrMsgTxt("Usage:\n [index deg] = mex_saliency_geometry(J,N,DOF);");


   double *ind = mxGetPr(prhs[0]);
   int N = (int)*mxGetPr(prhs[1]);

   int DOF = (int)*mxGetPr(prhs[2]);


//    cout<<" N : "<<N<<endl;

  /* for (int i = 0; i < N ; ++i)
   {
       for (int j = 0 ; j < 6 ; ++j)
           cout<<(int)ind[i*6+j]<<" ";

       cout<<endl;
   }
   */


   double *index; // = new double [N];


   plhs[0] = mxCreateDoubleMatrix(N,1, mxREAL);
   index = mxGetPr(plhs[0]);

   double *deg; // = new double [N];
   plhs[1] = mxCreateDoubleMatrix(N,1, mxREAL);
   deg = mxGetPr(plhs[1]);



   int *tabetiq = new int [N*DOF];
   int *tabi = new int [DOF];

   for(int j = 0 ; j < N ; ++j)
        index[j] = 0;


   for(int i = 0 ; i < DOF ; ++i)
   {
       tabi[i] = 0;
       for(int j = 0 ; j < N ; ++j)
            tabetiq[j*DOF+i] = 0;
   }

    int k = 0;
    int line;
    for(int i = 0 ; i < floor(N/DOF) ; ++i)
    {
        for(int j = 0 ; j < DOF ; ++j)
        {
             while(tabi[j] < N)
             {
                 line = (int)(ind[tabi[j]*DOF + j]);
                 if(tabetiq[j + line*DOF] ==0)
                 {
                    for( int jj = 0 ; jj < DOF ; ++jj)
                        tabetiq[(int)(line*DOF + jj)] = 1;

                     //      cout<<"blabla "<<endl;
                    index[k] =  ind[tabi[j]*DOF+ j];
                    k++;
                    tabi[j]++;
                    deg[k] = j;
                    break;
                 }
                 else
                 {
                   //  cout<<"occuped "<<endl;
                     tabi[j]++;
                 }

             }
        }
    }

    delete [] tabetiq;
    delete [] tabi;




}
