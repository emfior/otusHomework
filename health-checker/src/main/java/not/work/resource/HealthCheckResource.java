package not.work.resource;

import jakarta.ws.rs.GET;
import jakarta.ws.rs.Path;
import jakarta.ws.rs.Produces;
import jakarta.ws.rs.core.MediaType;
import not.work.model.HealthResponse;

@Path("/health/")
public class HealthCheckResource {


  @GET
  @Produces(MediaType.APPLICATION_JSON)
  public HealthResponse health() {
    return new HealthResponse("OK");
  }
}
