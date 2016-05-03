package org.opencompare;

import java.util.HashMap;

/**
 * Created by thibaut on 24/02/16.
 */
public class ValueNode {
    public HashMap<String, Integer> features;

    public ValueNode(String f) {
        features = new HashMap();
        features.put(f, 1);
    }

    public void addFeature(String f) {
        try {
            features.put(f, 1 + features.get(f));
        } catch(NullPointerException e) {
            features.put(f, 1);
        }
    }

    public int getFeature(String f) {
        try {
            return features.get(f);
        } catch(NullPointerException e) {
            return 0;
        }
    }
}
