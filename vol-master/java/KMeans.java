import java.io.IOException;
import java.util.*;
import java.io.*;
import java.net.URI;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.filecache.DistributedCache;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapred.*;
import org.apache.hadoop.mapred.Reducer;

@SuppressWarnings("deprecation")
public class KMeans {
    public static final String HDFS_OUTPUT = "/output/kmeans/";
    public static final String HDFS_INPUT = "/data/kmeans_data";
    public static final String JOB_NAME = "KMeans";
    public static final String TIMING_FILE = "/root/mount-master/timings/hadoopkmeans.txt";
    public static final int N_ITERATIONS = 10;
    public static final int DIM = 10;
    public static final int N_CENTROIDS = 10;
    public static DoubleArrayWritable[] centroids;

    public static class DoubleArrayWritable extends ArrayWritable {

        public DoubleArrayWritable() {
            super(DoubleWritable.class);
            DoubleWritable[] values = new DoubleWritable[DIM];
            for (int i = 0; i < DIM; i++) values[i] = new DoubleWritable();
            set(values);
        }


        public DoubleArrayWritable(DoubleWritable[] values) {
            super(DoubleWritable.class, values);
        }

        public static DoubleArrayWritable initUniform(double n) {
            DoubleWritable[] values = new DoubleWritable[DIM];
            for (int i = 0; i < DIM; i++) {
                values[i] = new DoubleWritable(n);
            }
            return new DoubleArrayWritable(values);
        }

        @Override
        public DoubleWritable[] get() {
            return (DoubleWritable[]) super.get();
        }

        @Override
        public String toString() {
            DoubleWritable[] values = get();
            String result = "";
            for (int i = 0; i < DIM; i++) {
                result += values[i].toString() + " ";
            }
            return result;
        }

        @Override
        public void readFields(DataInput in) throws IOException {
            DoubleWritable[] values = get();
            for (int i = 0; i < DIM; i++) {
                values[i].set(in.readDouble());
            }
            set(values);
        }
        @Override
        public void write(DataOutput out) throws IOException {
            DoubleWritable[] values = get();
            for (int i = 0; i < DIM; i++) {
                out.writeDouble(values[i].get());
            }
        }
    }

    /*
     * In Mapper class we are overriding configure function. In this we are
     * reading file from Distributed Cache and then storing that into instance
     * variable "mCenters"
     */
    public static class Map extends MapReduceBase implements
            Mapper<LongWritable, Text, IntWritable, DoubleArrayWritable> {
        @Override
        public void configure(JobConf job) {
            try {
                Path path = new Path(job.get("centroids"));
                FileSystem hdfs = FileSystem.get(new Configuration());
                DataInputStream reader = hdfs.open(path);
                try {
                    for (int i = 0; i < centroids.length; i++) {
                        centroids[i].readFields(reader);
                    }
                    System.out.println("@@@" + centroids);
                } finally {
                    reader.close();
                }
            } catch (IOException e) {
                System.err.println("Exception reading DistributedCache: " + e);
            }
        }

        /*
         * Map function will find the minimum center of the point and emit it to
         * the reducer
         */
        @Override
        public void map(LongWritable key, Text value,
                OutputCollector<IntWritable, DoubleArrayWritable> output,
                Reporter reporter) throws IOException {
            String line = value.toString();

            DoubleWritable point[] = new DoubleWritable[DIM];
            StringTokenizer tok = new StringTokenizer(line, " ");
            for (int i = 0; i < DIM; i++) {
                point[i] = new DoubleWritable(Double.parseDouble(tok.nextToken()));
            }
            
            int closestIdx = closestPoint(point, centroids);

            // Emit the nearest center and the point
            output.collect(new IntWritable(closestIdx),
                           new DoubleArrayWritable(point));
        }

        private int closestPoint(DoubleWritable[] point, DoubleArrayWritable[] centers) {
            int bestCenterIdx = 0;
            double closestCenterDist = Double.MAX_VALUE;
            for (int i = 0; i < centers.length; i++) {
                DoubleWritable[] centroid = centers[i].get();
                double dist = squaredDist(point, centroid);
                if (dist < closestCenterDist) {
                    closestCenterDist = dist;
                    bestCenterIdx = i;
                }
            }
            return bestCenterIdx;
        }

        private double squaredDist(DoubleWritable[] arr1, DoubleWritable[] arr2) {
            assert arr1.length == arr2.length;
            double result = 0;
            for (int i = 0; i < arr1.length; i++) {
                result += Math.pow(Math.abs(arr1[i].get() - arr2[i].get()), 2);
            }
            return result;
        }
    }

    public static class Reduce extends MapReduceBase implements
            Reducer<IntWritable, DoubleArrayWritable, DoubleArrayWritable, NullWritable> {

        /*
         * Reduce function will emit all the points to that center and calculate
         * the next center for these points
         */
        @Override
        public void reduce(IntWritable key, Iterator<DoubleArrayWritable> values,
                OutputCollector<DoubleArrayWritable, NullWritable> output, Reporter reporter)
                throws IOException {
            DoubleWritable[] newCenter = new DoubleWritable[DIM];
            double[] sums = new double[DIM];
            int valuesCount = 0;
            while (values.hasNext()) {
                DoubleWritable[] point = values.next().get();
                for (int i = 0; i < point.length; i++) {
                    double val = point[i].get();
                    sums[i] += val;
                }
                valuesCount++;
            }
            for (int i = 0; i < sums.length; i++) {
                newCenter[i] = new DoubleWritable(sums[i] / valuesCount);
            }

            output.collect(new DoubleArrayWritable(newCenter), NullWritable.get());
        }
    }

    public static void main(String[] args) throws Exception {        
        Path path = new Path(HDFS_OUTPUT + "0/part-00000");
        FileSystem hdfs = FileSystem.get(new Configuration());
        DataOutputStream out = hdfs.create(path);

        // Initialize centroids
        centroids = new DoubleArrayWritable[N_CENTROIDS];
        for (int i = 0; i < centroids.length; i++) {
            centroids[i] = DoubleArrayWritable.initUniform(i);
            centroids[i].write(out);
        }
        out.close();

        BufferedWriter writer = new BufferedWriter(new FileWriter(TIMING_FILE));
        long startTime = System.nanoTime();

        for (int i = 0; i < N_ITERATIONS; i++) {
            JobConf conf = new JobConf(KMeans.class);
            conf.set("centroids", HDFS_OUTPUT + i + "/part-00000");
            conf.setJobName(JOB_NAME);
            conf.setMapOutputKeyClass(IntWritable.class);
            conf.setMapOutputValueClass(DoubleArrayWritable.class);
            conf.setOutputKeyClass(DoubleArrayWritable.class);
            conf.setOutputValueClass(NullWritable.class);
            conf.setMapperClass(Map.class);
            conf.setReducerClass(Reduce.class);
            conf.setInputFormat(TextInputFormat.class);
            conf.setOutputFormat(TextOutputFormat.class);

            FileInputFormat.setInputPaths(conf, new Path(HDFS_INPUT));
            FileOutputFormat.setOutputPath(conf, new Path(HDFS_OUTPUT + (i + 1)));

            JobClient.runJob(conf);
            long endTime = System.nanoTime();
            long duration = (endTime - startTime);
            startTime = endTime;
            System.out.println("Iteration " + i + " took " + duration + "ns");
            writer.write(duration + "\n");
        }
        writer.close();
    }
}