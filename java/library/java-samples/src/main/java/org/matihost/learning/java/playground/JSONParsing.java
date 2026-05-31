package org.matihost.learning.java.playground;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.net.URI;
import java.util.HashMap;
import java.util.Map;

public class JSONParsing {

  public static void main(String[] args) throws Exception {
    ObjectMapper mapper = new ObjectMapper();


    while (true){
      long before = System.currentTimeMillis();

      URI feed = new URI("https://www.manton.org/feed.json");
      JsonNode node = mapper.readTree(feed.toURL());

      long duration = System.currentTimeMillis() - before;

      System.out.println(duration);

      Thread.sleep(5_000L);

    }

    // URI feed = new URI("https://www.manton.org/feed.json");
    // JsonNode node = mapper.readTree(feed.toURL());
    // printEntireHtlm(node);
    // countTags(node);

  }

  private static void countTags(JsonNode node) {
    JsonNode items = node.get("items");

    Map<String, Integer> tagsCount = new HashMap<>();

    if (items.isArray()){
      for (JsonNode item : items){
        JsonNode tags = item.get("tags");
        if (tags != null && tags.isArray()) {
          for (JsonNode tag : tags) {
            String tagValue = tag.toString();

            int newCount = 1;
            if (tagsCount.containsKey(tagValue)) {
              newCount =  ((Integer) tagsCount.get(tagValue)) + 1;
            }
            tagsCount.put(tagValue, newCount);
          }
        }
      }
    }

    for (Map.Entry<?, ?> entry: tagsCount.entrySet()){
      System.out.println(entry.getKey() + ": "+ entry.getValue());
    }
  }

  private static void printEntireHtlm(JsonNode node) {
    JsonNode items = node.get("items");

    StringBuilder html = new StringBuilder();
    if (items.isArray()){
      for (JsonNode item : items){
        html.append(item.get("content_html").toString());
      }
    }

    System.out.println(html);
  }
}
