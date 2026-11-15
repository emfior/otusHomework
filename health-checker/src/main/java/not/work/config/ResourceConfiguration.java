package not.work.config;

import not.work.resource.HealthCheckResource;
import org.glassfish.jersey.server.ResourceConfig;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Import({
    HealthCheckResource.class,
})
@Configuration
public class ResourceConfiguration extends ResourceConfig {
  public ResourceConfiguration() {
    register(HealthCheckResource.class);
  }
}
