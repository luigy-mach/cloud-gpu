/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// scalastyle:off println

import java.io._

import breeze.linalg.{squaredDistance, DenseVector, Vector}

import org.apache.spark.{SparkConf, SparkContext}

/**
 * K-means clustering.
 *
 * This is an example implementation for learning how to use Spark. For more conventional use,
 * please refer to org.apache.spark.ml.clustering.KMeans.
 */
object SparkKMeans {

  def parseVector(line: String): Vector[Double] = {
    DenseVector(line.split(' ').map(_.toDouble))
  }

  def closestPoint(p: Vector[Double], centers: Array[Vector[Double]]): Int = {
    var bestIndex = 0
    var closest = Double.PositiveInfinity

    for (i <- 0 until centers.length) {
      val tempDist = squaredDistance(p, centers(i))
      if (tempDist < closest) {
        closest = tempDist
        bestIndex = i
      }
    }

    bestIndex
  }

  def showWarning() {
    System.err.println(
      """WARN: This is a naive implementation of KMeans Clustering and is given as an example!
        |Please use org.apache.spark.ml.clustering.KMeans
        |for more conventional use.
      """.stripMargin)
  }

  def main(args: Array[String]) {

    if (args.length < 4) {
      System.err.println("Usage: SparkKMeans <master> <file> <k> <iters>")
      System.exit(1)
    }

    showWarning()

    val sc = new SparkContext(args(0), "SparkKMeans")

    //val writer = new BufferedWriter(new FileWriter("timings/sparkkmeans.txt"))
    val writer = new BufferedWriter(new FileWriter("/root/mount-master/timings/sparkkmeans.txt"))
    var startTime = System.nanoTime()

    val lines = sc.textFile(args(1))
    val data = lines.map(parseVector _).cache()
    val K = args(2).toInt
    val numIters = args(3).toInt

    val kPoints = data.takeSample(withReplacement = false, K, 42).toArray
    var tempDist = 1.0

    for (i <- 0 until numIters) {
      val closest = data.map (p => (closestPoint(p, kPoints), (p, 1)))

      val pointStats = closest.reduceByKey{case ((p1, c1), (p2, c2)) => (p1 + p2, c1 + c2)}

      val newPoints = pointStats.map {pair =>
        (pair._1, pair._2._1 * (1.0 / pair._2._2))}.collectAsMap()

      tempDist = 0.0
      for (i <- 0 until K) {
        tempDist += squaredDistance(kPoints(i), newPoints(i))
      }

      for (newP <- newPoints) {
        kPoints(newP._1) = newP._2
      }
      println("Finished iteration (delta = " + tempDist + ")")
      val endTime = System.nanoTime()
      val duration = (endTime - startTime)
      startTime = endTime
      println("Took " + duration + "ns")
      writer.write(duration + "\n")
    }

    writer.close()
    println("Final centers:")
    kPoints.foreach(println)
    sc.stop()
  }
}
// scalastyle:on println
