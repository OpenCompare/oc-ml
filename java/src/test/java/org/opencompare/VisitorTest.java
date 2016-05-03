package org.opencompare;

import org.opencompare.api.java.PCM;
import org.opencompare.api.java.impl.io.KMFJSONLoader;
import org.opencompare.api.java.*;
import org.opencompare.api.java.value.*;
import org.opencompare.api.java.io.PCMLoader;

import com.opencsv.CSVWriter;

import static org.junit.Assert.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.io.*;
import java.util.Iterator;

import org.junit.Test;

public class VisitorTest {
    HashMap<String, ValueNode> values;
    ArrayList<String> features; // Not set because we need well-defined order

    @Test
    public void statistiques() throws IOException {
        values = new HashMap();
        features = new ArrayList();

        File folder = new File("pcms800/");
        File[] pcms = folder.listFiles();

        for (File f : pcms) {
            if (f.isFile()) {
                PCMLoader loader = new KMFJSONLoader();
                PCM pcm = loader.load(f).get(0).getPcm();
                assertNotNull(pcm);

                for (Product product : pcm.getProducts()) {
                    for (Feature feature : pcm.getConcreteFeatures()) {
                        Cell cell = product.findCell(feature);

                        //String rawContent = cell.getRawContent();
                        String content = cell.getContent();
                        String feat = feature.getName();

                        if(!features.contains(feat))
                            features.add(feat);

                        if(values.containsKey(content)) {
                            values.get(content).addFeature(feat);
                        }
                        else {
                            values.put(content, new ValueNode(feat));
                        }
                    }
                }
            }
        }

        PrintWriter writer = new PrintWriter("output.csv");
        CSVWriter csvWriter = new CSVWriter(writer, ',', '"');
        String[] line = new String[features.size() + 1];

        line[0] = "Value";

        int size = features.size();

        // First row : features
        for(int i = 0; i < size; i++) {
            line[i + 1] = features.get(i).replaceAll("[\n\t\r ]", "_");
        }
        csvWriter.writeNext(line);

        for(String value : values.keySet()) {
            line[0] = value;
            for(int i = 0; i < size; i++) {
                line[i + 1] = "" + values.get(value).getFeature(features.get(i));
            }
            csvWriter.writeNext(line);
        }

        writer.close();

        /*
        System.out.println("Precompute distances");

        int max = 0;
        for(String key : values.keySet()) {
            int size = values.get(key).values.size();
            if(size > max)
                max = size;
        }
        System.out.println("# values : " + values.size());
        System.out.println("max : " + max);

        // Precompute distances
        for(String key : values.keySet()) {
            ValueNode feat = values.get(key);
            Iterator<String> it = feat.values.keySet().iterator();
            while(it.hasNext()) {
                String v1 = it.next();
                Iterator<String> it2 = feat.values.keySet().iterator();
                if (it2.hasNext()) {
                    it2.next(); // Skip v1
                    while(it2.hasNext()) {
                        String v2 = it2.next();
                        try {
                            HashMap<String, Integer> subdist = distances.get(v1);
                            try {
                                subdist.put(v2, 1 + subdist.get(v2));
                            } catch (NullPointerException e) {
                                subdist.put(v2, 1);
                            }
                        } catch (NullPointerException e) {
                            HashMap<String, Integer> subdist = new HashMap();
                            subdist.put(v2, 1);
                            distances.put(v1, subdist);
                        }
                    }
                }
                it.remove();
            }
        }
        */

        /*
        // Print results
        for(String key : values.keySet()) {
            System.out.println(values.get(key));
        }
        */
    }

}
