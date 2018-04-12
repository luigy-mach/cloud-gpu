import scala.util.Random
import java.io._

object KMeansDataGenerator {
    def main(args: Array[String]) {
        if (args.length < 3) {
            System.err.println("Usage: KMeansDataGenerator <file> <numfeatures> <records>")
            System.exit(1)
        }

        val file = args(0)
        val numFeatures = args(1).toInt
        val N = args(2).toInt

        val writer = new PrintWriter(new BufferedWriter(new FileWriter(file)))
        def loop(count:Int):Unit = {
            for( i <- 0 until count ){
                val point = Array.fill(numFeatures){Random.nextDouble}   
                writer.println(point.mkString(" "))
            }
        }
        loop(N)
        writer.close
    }
}
