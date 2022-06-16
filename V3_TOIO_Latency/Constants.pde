int minCoordX = 0;
int maxCoordX = 614;
int minCoordY = 0;
int maxCoordY= 433;
int matCol = 1;
int matRow = 1;

int MAT_WIDTH = maxCoordX - minCoordX;
int MAT_HEIGHT = maxCoordY - minCoordY;

int total_MAT_WIDTH = MAT_WIDTH * matCol;
int total_MAT_HEIGHT = MAT_HEIGHT * matRow;

int maxMotorSpeed = 115;

int nCubes =  1;//ne this constants depending on the number of toio you use

int appFrameRate = 30;

boolean enable3Dview = false;


boolean debugView = true;

float X_storage[] =  new float [200];
float Y_storage[] =  new float [200];
long start;
