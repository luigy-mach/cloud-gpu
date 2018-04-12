import java.io.IOException;
import java.util.*;
import java.io.*;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.*;
import org.apache.hadoop.mapred.*;
import java.lang.Math;

@SuppressWarnings("deprecation")
public class LogisticRegression {
  public static final String HDFS_OUTPUT = "/output/lr/";
  public static final String HDFS_INPUT = "/data/lr_data";
  public static final String JOB_NAME = "LogisticRegression";
  public static final String TIMING_FILE = "/root/mount-master/timings/hadooplr.txt";
  public static final int N_ITERATIONS = 10;
  public static Random random;
  public static DoubleArrayWritable weights;

  private static final int DIM = 10;

  public static class DoubleArrayWritable extends ArrayWritable {
    public static DoubleArrayWritable initRandom() {
      DoubleWritable[] values = new DoubleWritable[DIM];
      if (random == null) random = new Random();
      for (int i = 0; i < DIM; i++) {
        values[i] = new DoubleWritable(2 * random.nextDouble() - 1);
      }
      return new DoubleArrayWritable(values);
    }

    public DoubleArrayWritable() {
      super(DoubleWritable.class);
      DoubleWritable[] values = new DoubleWritable[DIM];
      for (int i = 0; i < DIM; i++) values[i] = new DoubleWritable();
      set(values);
    }
    public DoubleArrayWritable(DoubleWritable[] values) {
      super(DoubleWritable.class, values);
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
    public double dot(DoubleArrayWritable o) {
      DoubleWritable[] values = get();
      DoubleWritable[] other = o.get();
      double sum = 0;
      for (int i = 0; i < DIM; i++) {
        sum += values[i].get() * other[i].get();
      }
      return sum;
    }
    public void scale(double scaleFactor) {
      DoubleWritable[] values = get();
      for (int i = 0; i < DIM; i++) {
        values[i].set(values[i].get() * scaleFactor);
      }
    }
    public void add(DoubleArrayWritable o) {
      DoubleWritable[] values = get();
      DoubleWritable[] other = o.get();
      for (int i = 0; i < DIM; i++) {
        values[i].set(values[i].get() + other[i].get());
      }
    }
  }

  /* Everything maps to the same key - since we just want to sum all the vectors. */
  public static class Map extends MapReduceBase implements
      Mapper<LongWritable, Text, IntWritable, DoubleArrayWritable> {
    private final static IntWritable one = new IntWritable(1);
    @Override
    public void configure(JobConf job) {
      try {
        Path path = new Path(job.get("input_weights"));
        FileSystem hdfs = FileSystem.get(new Configuration());
        DataInputStream reader = hdfs.open(path);
        try {
          weights = new DoubleArrayWritable();
          weights.readFields(reader);
        } finally {
          reader.close();
        }
      } catch (IOException e) {
        System.err.println("Exception reading file: " + e);
      }
    }

    @Override
    public void map(LongWritable key, Text value,
        OutputCollector<IntWritable, DoubleArrayWritable> output, Reporter reporter)
        throws IOException {
      String line = value.toString();
      String[] parts = line.split(" ");
      if (parts.length != (DIM + 1)) {
        throw new RuntimeException("Invalid input file - wrong number of dimensions " + parts.length);
      }

      double y = Double.parseDouble(parts[0]);
      DoubleWritable[] values = new DoubleWritable[DIM];
      for (int i = 0; i < DIM; i++) {
        values[i] = new DoubleWritable(Double.parseDouble(parts[i + 1]));
      }
      DoubleArrayWritable x = new DoubleArrayWritable(values);

      x.scale((1 - 1.0/(1+(-y)*Math.exp(weights.dot(x)))) * -y);
      output.collect(one, x);
    }
  }

  public static class Combiner extends MapReduceBase implements
      Reducer<IntWritable, DoubleArrayWritable, IntWritable, DoubleArrayWritable> {
    private final static IntWritable one = new IntWritable(1);
    @Override
    public void reduce(IntWritable key, Iterator<DoubleArrayWritable> values,
        OutputCollector<IntWritable, DoubleArrayWritable> output, Reporter reporter)
        throws IOException {
      DoubleArrayWritable result = new DoubleArrayWritable();

      while (values.hasNext()) {
        DoubleArrayWritable arr = values.next();
        result.add(arr);
      }

      output.collect(one, result);
    }
  }

  public static class Reduce extends MapReduceBase implements
      Reducer<IntWritable, DoubleArrayWritable, NullWritable, DoubleArrayWritable> {
    private final static IntWritable one = new IntWritable(1);
    @Override
    public void reduce(IntWritable key, Iterator<DoubleArrayWritable> values,
        OutputCollector<NullWritable, DoubleArrayWritable> output, Reporter reporter)
        throws IOException {
      DoubleArrayWritable result = new DoubleArrayWritable();

      while (values.hasNext()) {
        DoubleArrayWritable arr = values.next();
        result.add(arr);
      }

      output.collect(NullWritable.get(), result);
    }
  }

  public static void main(String[] args) throws Exception {
    run(args);
  }

  private static void writeWeightsToFile(String path, FileSystem hdfs) throws Exception {
    DataOutputStream out = hdfs.create(new Path(path));
    weights.write(out);
    out.close();
  }

  public static void run(String[] args) throws Exception {
    // Initialize random weights
    FileSystem hdfs = FileSystem.get(new Configuration());
    weights = DoubleArrayWritable.initRandom();
    writeWeightsToFile(HDFS_OUTPUT + "0/weights", hdfs);

    BufferedWriter writer = new BufferedWriter(new FileWriter(TIMING_FILE));
    long startTime = System.nanoTime();

    for (int i = 0; i < N_ITERATIONS; i++) {
      JobConf conf = new JobConf(LogisticRegression.class);
      conf.set("input_weights", HDFS_OUTPUT + i + "/weights");
      conf.setJobName(JOB_NAME);
      conf.setMapOutputKeyClass(IntWritable.class);
      conf.setMapOutputValueClass(DoubleArrayWritable.class);
      conf.setOutputKeyClass(NullWritable.class);
      conf.setOutputValueClass(DoubleArrayWritable.class);
      conf.setMapperClass(Map.class);
      conf.setCombinerClass(Combiner.class);
      conf.setReducerClass(Reduce.class);
      // Output gradients to one file
      conf.setNumReduceTasks(1);
      conf.setInputFormat(TextInputFormat.class);
      conf.setOutputFormat(TextOutputFormat.class);

      FileInputFormat.setInputPaths(conf,
          new Path(HDFS_INPUT));
      FileOutputFormat.setOutputPath(conf, new Path(HDFS_OUTPUT + (i + 1)));

      JobClient.runJob(conf);

      DataInputStream reader = hdfs.open(new Path(HDFS_OUTPUT + (i + 1) + "/part-00000"));
      DoubleArrayWritable gradient;
      try {
        gradient = new DoubleArrayWritable();
        gradient.readFields(reader);
        weights.add(gradient);
        writeWeightsToFile(HDFS_OUTPUT + (i + 1) + "/weights", hdfs);
      } finally {
        reader.close();
      }

      long endTime = System.nanoTime();
      long duration = (endTime - startTime);
      startTime = endTime;
      System.out.println("Iteration " + i + " took " + duration + "ns");
      writer.write(duration + "\n");
    }
    writer.close();
  }
}