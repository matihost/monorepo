package org.matihost.algorithms.euler;

/**

 By starting at the top of the triangle below and moving to adjacent numbers on the row below, the maximum total from top to bottom is 23.

   3
  7 4
 2 4 6
8 5 9 3

That is, 3 + 7 + 4 + 9 = 23.

 Find the maximum total from top to bottom of the triangle below.

 */
public class Problem18 {


    public static int maxPathLength(int[][] graph) {
        int rows = graph.length;

        for (int j=1;j<rows;j++){
            int [] prevRow = graph[j-1];
            int [] currRow = graph[j];
            for (int i=0;i<currRow.length;i++){
                int maxParent = Integer.MIN_VALUE;
                if (i-1 >= 0){
                    maxParent = Math.max(maxParent,prevRow[i-1]);
                }
                if (i < prevRow.length){
                    maxParent = Math.max(maxParent,prevRow[i]);
                }
                currRow[i] +=maxParent;
            }
        }

        int result = 0;
        for (int v : graph[rows-1]){
            result = Math.max(result, v);
        }
        return result;
    }


    public static void main(String [] args){
        int [][] sample=
        {
           {3},
           {7,4},
          {2,4,6},
         {8,5,9,3}
        };
        // int [][] sampleAfter=
        //         {
        //                 {3},
        //                 {10,7},
        //                 {12,14,13},
        //                {22,19,23,16}
        //         };
        System.out.println(maxPathLength(sample));
        int [][] graph= {
                {75},
                {95,64},
                {17,47,82},
                {18,35,87,10},
                {20,4,82,47,65},
                {19,1,23,75,3,34},
                {88,2,77,73,7,63,67},
                {99,65,4,28,6,16,70,92},
                {41,41,26,56,83,40,80,70,33},
                {41,48,72,33,47,32,37,16,94,29},
                {53,71,44,65,25,43,91,52,97,51,14},
                {70,11,33,28,77,73,17,78,39,68,17,57},
                {91,71,52,38,17,14,91,43,58,50,27,29,48},
                {63,66,4,68,89,53,67,30,73,16,69,87,40,31},
                {4,62,98,27,23,9,70,98,73,93,38,53,60,4,23}
        };
        System.out.println(maxPathLength(graph));
    }


}

