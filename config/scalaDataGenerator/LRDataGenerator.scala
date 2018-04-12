import scala.util.Random
import java.io._

object LRDataGenerator {
    def main(args: Array[String]) {
        if (args.length < 3) {
            System.err.println("Usage: LRDataGenerator <file> <numfeatures> <records>")
            System.exit(1)
        }

        val file = args(0)
        val numFeatures = args(1).toInt
        val N = args(2).toInt

        val writer = new PrintWriter(new BufferedWriter(new FileWriter(file)))
        def loop(count:Int):Unit = {
            for( i <- 0 until count ){
                var arr: Array[Double] = Array.fill(numFeatures + 1){Random.nextDouble}
                arr(0) = if (Random.nextBoolean) 1 else -1
                writer.println(arr.mkString(" "))
            }
        }
        loop(N)
        writer.close
    }
}
