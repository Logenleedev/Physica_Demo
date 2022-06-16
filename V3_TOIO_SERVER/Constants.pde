 //Constants for Configurations
int numPiMax = 14; 
int cubePerPi = 5;

int[][] cubeID = new int[numPiMax][cubePerPi];

// *SET your toio ID HERE (0 is used for empty)
int[][] SET_ID = {{24,0,0,0,0}};
//int[][] SET_ID = {{41, 42, 43, 44, 45}, {21,23,24,26,27}}; 
//int[][] SET_ID = {{20,8,9,10,12}, {13,14,15,16,17}, {18,19,0,0,0}};// {76,77,78,0,0}}; //, {9, 15, 63, 18, 24}}; 
int numPi_temp = 1;// number of rasberry pi (not the ID, just the num of rasPis)


// if you want to set cube ID in order  `
boolean cubeIDinOrder = false;
int startCubeID = 41;

int fps = 100; // fps of the app (don't change)
int toioFps = 60; // fps to control toio on pi (don't change)

//Mat Config
// set this for multi-mat configuration
int minCoordX = 35;
int maxCoordX = 1000;
int minCoordY = 35;
int maxCoordY= 1000;
int matCol = 1;
int matRow = 1;

//int minCoordX = 40;
//int maxCoordX = 900;
//int minCoordY = 40;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              ;
//int maxCoordY= 900;
//int matCol = 1;
//int matRow = 1;


void assignCubeIDinOrder() {
  if (cubeIDinOrder) {
    int id =  startCubeID;
    for (int i = 0; i < numPiMax; i++) {
      for (int j = 0; j < cubePerPi; j++) {
        cubeID[i][j] = id;
        id++;
      }
    }

  
  } else {
    
    for(int j = 0; j < numPi_temp; j++)
    for (int i = 0; i < cubePerPi; i++) {
      cubeID[j][i] = SET_ID[j][i];
    }
    
  }
}
