package jwt;

import io.vertx.core.Vertx;
import io.vertx.core.json.JsonObject;
import io.vertx.core.json.JsonArray;
import io.vertx.ext.auth.JWTOptions;
import io.vertx.ext.auth.PubSecKeyOptions;
import io.vertx.ext.auth.jwt.JWTAuth;
import io.vertx.ext.auth.jwt.JWTAuthOptions;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

public class GenerateJWT {

  private enum Algo {
    RS256
  }

  public static void main(String[] args) throws Exception {
    Vertx vertx = Vertx.vertx();

    

    String privateRSAKey = Files.readString(Path.of("RSA_private_key.pem"));
    String publicRSAKey = Files.readString(Path.of("RSA_public.pem"));

    JsonObject jsonTokenPayload = new JsonObject()
        .put("permissions",  new JsonArray().add("*:*"))
        .put("exp", (System.currentTimeMillis() / 1000) + 3600);

    System.out.printf("\nRSA JWT: %s\n",generate(vertx, Algo.RS256, privateRSAKey, publicRSAKey, jsonTokenPayload));
  }

  private static String generate(Vertx vertx, Algo algo, String privateKey,
      String publicKey, JsonObject payload) throws IOException {
    JWTAuth provider = JWTAuth.create(vertx, new JWTAuthOptions()
        .addPubSecKey(new PubSecKeyOptions()
            .setAlgorithm(algo.name())
            .setBuffer(publicKey))
        .addPubSecKey(new PubSecKeyOptions()
            .setAlgorithm(algo.name())
            .setBuffer(privateKey)));

    return provider.generateToken(
        payload,
        new JWTOptions().setAlgorithm(algo.name()));
  }
}