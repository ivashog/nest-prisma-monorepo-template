import { INestApplication } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import * as SWStats from 'swagger-stats';
import { ApiConfig } from '@app/common/config';

export function initSwaggerModule(app: INestApplication, config: ApiConfig): void {
    const { appName, version, description, swagger, apiMonitoring } = config;

    /** 1. Generate swagger specification */
    const swaggerConfig = new DocumentBuilder()
        .setTitle(appName)
        .setDescription(description)
        .setVersion(version)
        .addServer(swagger.apiBaseUrl, 'Current server')
        .addBearerAuth();
    if (swagger.remoteServers.length) {
        swagger.remoteServers.forEach((url, idx) =>
            swaggerConfig.addServer(url, `Remote server ${idx + 1}`),
        );
    }
    const swaggerSpec = SwaggerModule.createDocument(app, swaggerConfig.build());

    /** 2. Setup swagger docs module if enabled */
    if (swagger.isEnabled) {
        SwaggerModule.setup(swagger.uriPath, app, swaggerSpec, {
            customSiteTitle: appName,
            swaggerOptions: {
                displayRequestDuration: true,
            },
        });
    }

    /** 3. Setup api monitoring with swagger-stats module if enabled */
    if (apiMonitoring.isEnabled) {
        app.use(
            SWStats.getMiddleware({
                ...apiMonitoring.swStatsOptions,
                swaggerSpec,
            }),
        );
    }
}
