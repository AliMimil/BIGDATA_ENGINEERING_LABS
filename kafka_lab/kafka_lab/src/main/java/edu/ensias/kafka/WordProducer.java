package edu.ensias.kafka;

import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringSerializer;

import java.util.Properties;
import java.util.Scanner;

public class WordProducer {
    public static void main(String[] args) {
        String bootstrapServers = "localhost:9092";
        String topic = "words-topic";

        // Configuration du producteur Kafka
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        KafkaProducer<String, String> producer = new KafkaProducer<>(props);

        Scanner scanner = new Scanner(System.in);
        System.out.println("Tapez du texte (CTRL+C pour quitter) :");

        while (true) {
            String line = scanner.nextLine();
            String[] words = line.split("\\s+"); // découpe en mots
            for (String word : words) {
                ProducerRecord<String, String> record = new ProducerRecord<>(topic, word);
                producer.send(record);
            }
        }
        // producer.close(); // optionnel car boucle infinie
    }
}

