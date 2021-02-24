package ca.ualberta.cs.hdbscanstar;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;

import ca.ualberta.cs.distance.CosineSimilarity;
import ca.ualberta.cs.distance.DistanceCalculator;
import ca.ualberta.cs.distance.EuclideanDistance;
import ca.ualberta.cs.distance.ManhattanDistance;
import ca.ualberta.cs.distance.PearsonCorrelation;
import ca.ualberta.cs.distance.SupremumDistance;

public class ApproxGLOSHDD {

	private double[][] trainingSet;
	private int minPts;
	private int minClSize;
	private DistanceCalculator distanceFunction;
	private HDBSCANStarObject clusterHierarchy;
	private double[] coreDistances;
	
	public ApproxGLOSHDD(double[][] trainingSet, int minPts, int minClSize) {
		
		this.trainingSet = trainingSet;
		this.minPts = minPts;
		this.minClSize = minClSize;
		this.distanceFunction = new EuclideanDistance();
	}
	
	public double[] trainGLOSHDD() {
		int numTrainingPoints = this.trainingSet.length;
		ArrayList<OutlierScore> outlierScores = new ArrayList<OutlierScore>(numTrainingPoints);
		HDBSCANStarObject currentHierarchy;
					
			currentHierarchy = runHDBSCANStar(null);
			
		for (int i = 0; i < numTrainingPoints; i++) {
			//Compute outlier score for test point:
			outlierScores.add(HDBSCANStar.calculateOutlierScore(currentHierarchy.clusters, currentHierarchy.pointNoiseLevels,
					currentHierarchy.pointLastClusters, currentHierarchy.coreDistances, i, i));
		}
		this.clusterHierarchy = currentHierarchy;
					
		//Write training data outlier scores:
		double[] scores = new double[numTrainingPoints];
		for (int i=0; i < numTrainingPoints; i++) {
			scores[i] = outlierScores.get(i).getScore();
		}
		
		
		return scores;
	}
	
	public double[] computeScores(double[][] testSet) {
	

		int numTestPoints = testSet.length;
//		ArrayList<OutlierScore> outlierScores = new ArrayList<OutlierScore>(numTestPoints);
//		HDBSCANStarObject currentHierarchy;
//		
//		//Loop over test points
//		for (int i=0; i < numTestPoints; i++) {
//			
//			currentHierarchy = runHDBSCANStar(testSet[i]);
//			
//			//Compute outlier score for test point:
//			outlierScores.add(HDBSCANStar.calculateOutlierScore(currentHierarchy.clusters, currentHierarchy.pointNoiseLevels,
//					currentHierarchy.pointLastClusters, currentHierarchy.coreDistances, i, currentHierarchy.numPoints-1));
//			currentHierarchy = null;
//			
//		}
//		
//		//Write test data outlier scores:
		double[] scores = new double[numTestPoints];
		double coreDistance;
		double closestMRD;
		double noiseLevel;
		int closestPoint;
		int testLastCluster;
		
		//Loop over test points
		for (int i=0; i < numTestPoints; i++) {
			coreDistance = calculateCoreDistance(testSet[i], this.distanceFunction);
			closestPoint = findClosestPoint(testSet[i], coreDistance);
			closestMRD = computeMRD(testSet[i], coreDistance, this.trainingSet[closestPoint], this.coreDistances[closestPoint]);
			testLastCluster = this.clusterHierarchy.pointLastClusters[closestPoint];
			noiseLevel = this.clusterHierarchy.pointNoiseLevels[closestPoint];
			if (this.clusterHierarchy.pointNoiseLevels[closestPoint] < closestMRD) {
				noiseLevel = closestMRD;
				while(this.clusterHierarchy.clusters.get(testLastCluster).getBirthLevel() < closestMRD) {
					testLastCluster = this.clusterHierarchy.clusters.get(testLastCluster).getParent().getLabel();
				}
			}
			scores[i] = calculateTestScore(testLastCluster, noiseLevel);
		}	
		return scores;
	}
	

	private double calculateTestScore(int cluster, double epsilon) {
		double epsilon_max = this.clusterHierarchy.clusters.get(cluster).getPropagatedLowestChildDeathLevel();
			
		double score = 0;
		if (epsilon_max == Double.MAX_VALUE)
			epsilon_max = this.clusterHierarchy.clusters.get(cluster).getDeathLevel();
		if (epsilon != 0)
			score = 1-(epsilon_max/epsilon);
			
		return score;
	}

	private double computeMRD(double[] point1, double coreDistance1, double[] point2,
			double coreDistance2) {
		double distance = distanceFunction.computeDistance(point1, point2);
		double MRD = distance;
		if (coreDistance1 > MRD)
			MRD = coreDistance1;
		if (coreDistance2 > MRD)
			MRD = coreDistance2;
		
		return MRD;
	}

	private int findClosestPoint(double[] point, double coreDistance) {
		int closestPoint = -1;
		double closestDistance = Double.MAX_VALUE;
		double MRD;
		
		for (int i=0; i < this.trainingSet.length; i++) {
			MRD = computeMRD(point, coreDistance, this.trainingSet[i], this.coreDistances[i]);
			if (MRD < closestDistance) {
				closestPoint = i;
				closestDistance = MRD;
			}
		}
		
		return closestPoint;
	}

	private double calculateCoreDistance(double[] point, DistanceCalculator distanceFunction) {
		int numNeighbors = this.minPts - 1;
		double coreDistance;
		double[][] dataSet = this.trainingSet;
		
		if (numNeighbors == 0) {
			coreDistance = 0;
			return coreDistance;
		}
		
		double[] kNNDistances = new double[numNeighbors];
		for (int i = 0; i < numNeighbors; i++) {
			kNNDistances[i] = Double.MAX_VALUE;
		}
		
		for (int neighbor = 0; neighbor < dataSet.length; neighbor++) {
			double distance = distanceFunction.computeDistance(point, dataSet[neighbor]);
			
			int neighborIndex = numNeighbors;
			while (neighborIndex >= 1 && distance < kNNDistances[neighborIndex-1])
				neighborIndex--;
			
			if (neighborIndex < numNeighbors) {
				for (int shiftIndex = numNeighbors-1; shiftIndex > neighborIndex; shiftIndex--) {
					kNNDistances[shiftIndex] = kNNDistances[shiftIndex-1];
				}
				kNNDistances[neighborIndex] = distance;
			}
		}
		coreDistance = kNNDistances[numNeighbors-1];
		return coreDistance;
	}

	public HDBSCANStarObject runHDBSCANStar(double[] testPoint) {
		
		HDBSCANStarObject currentHierarchy = new HDBSCANStarObject();
				
		//Read in constraints:
		ArrayList<Constraint> constraints = null;
		
		double[] coreDistances;
		double[][] ddSet;
		int numPoints;
		
		//Add current test point to training data if available:
		if (testPoint == null) {
			numPoints = this.trainingSet.length;
			ddSet = this.trainingSet;
		} else {
		numPoints = this.trainingSet.length + 1;
		ddSet = Arrays.copyOf(this.trainingSet, numPoints);
		ddSet[numPoints-1] = testPoint;
		}
		
		//Compute core distances:
		coreDistances = HDBSCANStar.calculateCoreDistances(ddSet, this.minPts, this.distanceFunction);
		if (testPoint == null) {
			this.coreDistances = coreDistances;
		}

		//Calculate minimum spanning tree:
		UndirectedGraph mst = HDBSCANStar.constructMST(ddSet, coreDistances, true, this.distanceFunction);
		mst.quicksortByEdgeWeight();

		//Remove references to unneeded objects:
		ddSet = null;
		
		double[] pointNoiseLevels = new double[numPoints];
		int[] pointLastClusters = new int[numPoints];

		//Compute hierarchy and cluster tree:
		ArrayList<Cluster> clusters = null;
		try {
			clusters = HDBSCANStar.computeHierarchyAndClusterTree(mst, this.minClSize, 
					false, constraints, null, null, ",", pointNoiseLevels, pointLastClusters);
		}
		catch (IOException ioe) {
			System.err.println("Error writing to hierarchy file or cluster tree file.");
			System.exit(-1);
		}

		//Remove references to unneeded objects:
		mst = null;
		
		//Propagate clusters:
		HDBSCANStar.propagateTree(clusters);
		
		currentHierarchy.clusters = clusters;
		currentHierarchy.pointNoiseLevels = pointNoiseLevels;
		currentHierarchy.pointLastClusters = pointLastClusters;
		currentHierarchy.coreDistances = coreDistances;
		currentHierarchy.numPoints = numPoints;
		
		return currentHierarchy;
	}
	
	public void printVars() {
		for (int i = 0; i < this.trainingSet.length; i++) {
			System.out.println(this.trainingSet[i][0] + " " + this.trainingSet[i][1]);
		}
	}
	
	public int getMinPts() {
		return this.minPts;
	}
	
	public int getMinClSize() {
		return this.minClSize;
	}
	
	public double[][] getData() {
		return this.trainingSet;
	}
	
	private static class HDBSCANStarObject {
		public ArrayList<Cluster> clusters;
		double[] pointNoiseLevels;
		int[] pointLastClusters;
		double[] coreDistances;
		int numPoints;
	}
	
}
