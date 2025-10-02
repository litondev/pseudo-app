window.onload = function() {
  //<editor-fold desc="Changeable Configuration Block">

  // the following lines will be replaced by docker/configurator, when it runs in a docker-container
  window.ui = SwaggerUIBundle({
    urls: [
      {
        url: "/docs/combined_swagger.yaml",
        name: "Complete API Documentation"
      },
      {
        url: "/docs/status_swagger.yaml", 
        name: "Status Endpoint"
      },
      {
        url: "/docs/health_swagger.yaml",
        name: "Health Endpoint"
      }
    ],
    dom_id: '#swagger-ui',
    deepLinking: true,
    presets: [
      SwaggerUIBundle.presets.apis,
      SwaggerUIStandalonePreset
    ],
    plugins: [
      SwaggerUIBundle.plugins.DownloadUrl
    ],
    layout: "StandaloneLayout"
  });

  //</editor-fold>
};
