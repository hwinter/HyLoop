// ex11-1 - accessing command line arguments
#include <iostream>
#include <string>
using namespace std;
int main(int argc,char *argv[])
{
    cout << "argc=" << argc << endl;
    for (int i=1;i<argc;i++) 
        cout << "argv[" << i << "]=" 
             << argv[i] << endl;
    return(0);
}
